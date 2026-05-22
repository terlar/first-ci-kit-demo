{
  needs = [
    { stack = "networking"; }
    {
      stack = "security";
      component = "iam";
    }
  ];
}
