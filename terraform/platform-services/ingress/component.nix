{
  needs = [
    { stack = "cluster"; }
    {
      stack = "security";
      component = "certs";
    }
  ];
}
