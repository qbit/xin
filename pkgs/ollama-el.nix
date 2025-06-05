{
  trivialBuild,
  fetchFromGitHub,
  ...
}:
trivialBuild {
  pname = "ollama";
  version = "unstable-2023-08-28";
  src = fetchFromGitHub {
    owner = "zweifisch";
    repo = "ollama";
    rev = "19e8babd6eceef37ca4bf9a58bc666d0e55b70c6";
    hash = "sha256-u3+V7bLH/l2hcVoSdQYsQNKDpz4pwPFjAn1ED8vSk50=";
  };
}
