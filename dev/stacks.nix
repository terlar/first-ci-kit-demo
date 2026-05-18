{
  networking = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      vpc = { };
      dns = { };
    };
  };

  security = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      iam = { };
      certs = { };
    };
  };

  cluster = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      control-plane.needs = [ { stack = "networking"; } ];
      node-pools.needs = [ { component = "control-plane"; } ];
    };
  };

  database = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      postgres.needs = [
        { stack = "networking"; }
        {
          stack = "security";
          component = "iam";
        }
      ];
      redis.needs = [ { stack = "networking"; } ];
    };
  };

  observability = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      metrics.needs = [ { stack = "cluster"; } ];
      logging.needs = [ { stack = "cluster"; } ];
      alerting.needs = [ { component = "metrics"; } ];
    };
  };

  platform-services = {
    deployments = {
      dev = { };
      stg = { };
    };

    components = {
      ingress.needs = [
        { stack = "cluster"; }
        {
          stack = "security";
          component = "certs";
        }
      ];
      cert-manager.needs = [
        { stack = "cluster"; }
        {
          stack = "networking";
          component = "dns";
        }
      ];
    };
  };
}
