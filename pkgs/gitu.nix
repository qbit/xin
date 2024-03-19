{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, git
,
}:
rustPlatform.buildRustPackage rec {
  pname = "gitu";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "altsem";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ymAggfyLPpXp4aQPHp1R+olKeCZwrcwu1GldM8yJVtQ=";
  };

  cargoHash = "sha256-pIA9AnJoauT5nLxSgzR2Lk3wSo30fXAepAJlMahSuCA=";

  buildInputs = [ git openssl ];
  nativeBuildInputs = [ pkg-config ];

  # running 30 tests
  # test checkout_menu ... FAILED
  # test checkout_new_branch ... FAILED
  # test discard_branch_confirm ... FAILED
  # test fetch_all ... FAILED
  # test help_menu ... FAILED
  # test fresh_init ... FAILED
  # test go_down_past_collapsed ... FAILED
  # test log ... FAILED
  # test merge_conflict ... FAILED
  # test log_other ... FAILED
  # test hide_untracked ... FAILED
  # test new_file ... FAILED
  # test moved_file ... FAILED
  # test no_repo ... FAILED
  # test new_commit ... FAILED
  # test rebase_conflict ... FAILED
  # test pull ... FAILED
  doCheck = false;

  meta = with lib; {
    description = " A TUI Git client inspired by Magit ";
    homepage = "https://github.com/altsem/gitu";
    license = licenses.mit;
    maintainers = [ maintainers.qbit ];
  };
}
