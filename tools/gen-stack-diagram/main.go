package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	stdlog "log"
	"log/slog"
	"os"
	"sort"
	"strings"

	"oss.terrastruct.com/d2/d2graph"
	"oss.terrastruct.com/d2/d2layouts/d2elklayout"
	"oss.terrastruct.com/d2/d2lib"
	"oss.terrastruct.com/d2/d2renderers/d2svg"
	d2log "oss.terrastruct.com/d2/lib/log"
	"oss.terrastruct.com/d2/lib/textmeasure"
)

// stackColors maps stack names to [fill, stroke] hex colours.
var stackColors = map[string][2]string{
	"networking":        {"#dbeafe", "#3b82f6"},
	"security":          {"#fef9c3", "#eab308"},
	"cluster":           {"#dcfce7", "#22c55e"},
	"database":          {"#fce7f3", "#ec4899"},
	"observability":     {"#ede9fe", "#8b5cf6"},
	"platform-services": {"#ffedd5", "#f97316"},
}

type need struct {
	Stack     string `json:"stack"`
	Component string `json:"component"`
}

type component struct {
	Needs []need `json:"needs"`
}

type stack struct {
	Components map[string]component `json:"components"`
}

func sortedKeys[V any](m map[string]V) []string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	return keys
}

func generateD2(stacks map[string]stack, direction string) string {
	var b strings.Builder

	fmt.Fprintf(&b, "direction: %s\n\n", direction)

	// Containers and nodes.
	for _, stackName := range sortedKeys(stacks) {
		s := stacks[stackName]
		label := strings.ReplaceAll(strings.Title(strings.ReplaceAll(stackName, "-", " ")), " ", " ")
		fmt.Fprintf(&b, "%s: %s {\n", stackName, label)
		for _, compName := range sortedKeys(s.Components) {
			fmt.Fprintf(&b, "  %s: %s\n", compName, compName)
		}
		if colors, ok := stackColors[stackName]; ok {
			fmt.Fprintf(&b, "  style.fill: %q\n", colors[0])
			fmt.Fprintf(&b, "  style.stroke: %q\n", colors[1])
		}
		fmt.Fprintf(&b, "}\n\n")
	}

	// Edges.
	for _, stackName := range sortedKeys(stacks) {
		s := stacks[stackName]
		for _, compName := range sortedKeys(s.Components) {
			comp := s.Components[compName]
			target := fmt.Sprintf("%s.%s", stackName, compName)
			for _, n := range comp.Needs {
				var source string
				switch {
				case n.Stack != "" && n.Component != "":
					source = fmt.Sprintf("%s.%s", n.Stack, n.Component)
				case n.Stack != "":
					source = n.Stack
				case n.Component != "":
					// Same-stack component reference.
					source = fmt.Sprintf("%s.%s", stackName, n.Component)
				}
				if source != "" {
					fmt.Fprintf(&b, "%s -> %s\n", source, target)
				}
			}
		}
	}

	return b.String()
}

func renderSVG(d2src string) ([]byte, error) {
	ruler, err := textmeasure.NewRuler()
	if err != nil {
		return nil, fmt.Errorf("create ruler: %w", err)
	}

	renderOpts := &d2svg.RenderOpts{}
	compileOpts := &d2lib.CompileOptions{
		Ruler: ruler,
		LayoutResolver: func(_ string) (d2graph.LayoutGraph, error) {
			return d2elklayout.DefaultLayout, nil
		},
	}

	ctx := d2log.With(context.Background(), slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{
		Level: slog.LevelWarn,
	})))

	diagram, _, err := d2lib.Compile(ctx, d2src, compileOpts, renderOpts)
	if err != nil {
		return nil, fmt.Errorf("compile: %w", err)
	}

	svg, err := d2svg.Render(diagram, renderOpts)
	if err != nil {
		return nil, fmt.Errorf("render: %w", err)
	}
	return svg, nil
}

func writeFile(path, content string) error {
	if err := os.MkdirAll(dirOf(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(content), 0o644)
}

func dirOf(path string) string {
	idx := strings.LastIndex(path, "/")
	if idx < 0 {
		return "."
	}
	return path[:idx]
}

func main() {
	direction := flag.String("direction", "right", "D2 layout direction (right, down, left, up)")
	d2Out := flag.String("d2", "docs/stacks.d2", "output path for D2 source")
	svgOut := flag.String("svg", "docs/stacks.svg", "output path for SVG")
	flag.Parse()

	var stacks map[string]stack
	if err := json.NewDecoder(os.Stdin).Decode(&stacks); err != nil {
		stdlog.Fatalf("decode stacks JSON: %v", err)
	}

	d2src := generateD2(stacks, *direction)

	if err := writeFile(*d2Out, d2src); err != nil {
		stdlog.Fatalf("write %s: %v", *d2Out, err)
	}
	stdlog.Printf("wrote %s", *d2Out)

	svg, err := renderSVG(d2src)
	if err != nil {
		stdlog.Fatalf("render SVG: %v", err)
	}

	if err := writeFile(*svgOut, string(svg)); err != nil {
		stdlog.Fatalf("write %s: %v", *svgOut, err)
	}
	stdlog.Printf("wrote %s", *svgOut)
}
