{
  lib,
  ...
}:
{
  name,
  namespace,
  age,
}:
{
  secrets.${name} = {
    metadata.namespace = namespace;
    data = {
      secret = "ref+file:///run/agenix/" + age;
    };
  };
}
