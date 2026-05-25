{
  needs = [
    { stack = "cluster"; }
    {
      stack = "networking";
      component = "dns";
    }
  ];
}
