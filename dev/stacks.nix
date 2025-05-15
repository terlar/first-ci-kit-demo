{
  stack-a = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a = { };
      cmp-b.needs = [ { component = "cmp-a"; } ];
    };
  };

  stack-b = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a.needs = [
        {
          stack = "stack-a";
          component = "cmp-b";
        }
      ];
      cmp-b.needs = [ { stack = "stack-a"; } ];
    };
  };
}
