{
  stack-a = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a = { };
      cmp-b.needs = [ { component = "cmp-a"; } ];
      cmp-c = { };
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
  stack-c = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a = { };
      cmp-b = { };
      cmp-c = { };
    };
  };
  stack-d = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a.needs = [ { stack = "stack-c"; } ];
    };
  };
  stack-e = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a = { };
      cmp-b = { };
    };
  };
  stack-f = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      cmp-a = { };
    };
  };
}
