{
  first-ci-kit.pipelines.default = {
    gitlab-ci = {
      defaultStage = "main";
      settings = {
        default.image = "alpine";
        stages = [ "main" ];
        workflow.rules = [
          { "if" = "$CI_MERGE_REQUEST_TARGET_BRANCH_PROTECTED"; }
          { "if" = "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH"; }
        ];
      };
    };

    github-actions = {
      defaultRunsOn = "ubuntu-latest";
      summaryJob.enable = true;
      settings = {
        name = "CI";
      };
    };

    process-compose.cli.environment.PC_DISABLE_TUI = true;

    jobSets.stg.needs = [ { jobSet = "dev"; } ];
  };
}
