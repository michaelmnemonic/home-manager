{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.llama-cpp;
  # the -hf downloader (llama.cpp b10408) uses the huggingface_hub layout and
  # writes only inside the model directory (blobs/, snapshots/, refs/);
  # "owner/repo-GGUF:QUANT" -> "models--owner--repo-GGUF"
  hfModelDir = model: let
    repo = lib.head (lib.splitString ":" model);
    ownerRepo = lib.splitString "/" repo;
  in
    if lib.length ownerRepo != 2
    then throw "universe.llama-cpp.models entries must be in owner/repo[:quant] form, got: \"${model}\""
    else "${config.home.homeDirectory}/.cache/huggingface/hub/models--${lib.replaceStrings ["/"] ["--"] repo}";

  # systemd unit names allow only [a-zA-Z0-9:_.\-] (among few others),
  # so "/" and ":" from the model ref become "-"
  unitSuffix = model: lib.replaceStrings ["/" ":"] ["-" "-"] model;
in {
  options.universe.llama-cpp = {
    enable = lib.mkEnableOption "Local LLM setup with llama.cpp";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL"];
      description = "LLMs to pre-download, in llama.cpp -hf owner/repo[:quant] shorthand. One systemd unit per model.";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services = builtins.listToAttrs (map (model:
      lib.nameValuePair "llama-model-download-${unitSuffix model}" {
        Unit = {
          Description = "Download LLM ${model}";
          # ReadWritePaths needs the cache dir to exist before the unit starts;
          # it is created by the home-manager activation script and by
          # systemd-tmpfiles-setup.service at user-manager start
          After = ["systemd-tmpfiles-setup.service"];
          Requires = ["systemd-tmpfiles-setup.service"];
        };
        Service = {
          Type = "oneshot";
          # a potentionally long-running download must not be killed by the default 90s start timeout
          TimeoutStartSec = "infinity";
          RemainAfterExit = true;
          Slice = "background.slice";
          # llama-fit-params is not actually the correct tool, but llama.cpp does not provide a download-only tool
          ExecStart = "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf ${model}";
          Restart = "on-failure";
          # exponential backoff: 10s 20s 40s 80s 160s 320s, then capped at 8min
          RestartSec = "10";
          RestartSteps = "6";
          RestartMaxDelaySec = "8min";
          # sandbox: read-only filesystem incl. /home and all
          # sibling model dirs — writable is only this model's cache dir;
          # GPU access deliberately removed (PrivateDevices hides /dev/dri):
          # the download still works, only the fitted params become CPU-only;
          # network cannot be filtered for user units
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          ReadWritePaths = [(hfModelDir model)];
          PrivateTmp = true;
          PrivateDevices = true;
          NoNewPrivileges = true;
          RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
          SystemCallFilter = ["@system-service"];
        };
        Install = {
          # user manager reaches default.target on the first login of the user
          # after boot — graphical, tty or ssh alike
          WantedBy = ["default.target"];
        };
      })
    (lib.unique cfg.models));

    # pre-create the cache dirs outside the sandbox: ReadWritePaths needs an
    # existing path and inside the unit the filesystem is read-only;
    # tmpfiles covers user-manager start, this covers mid-session switches
    systemd.user.tmpfiles.rules = map (model: "d ${hfModelDir model} - - - - -") (lib.unique cfg.models);
    home.activation.llama-cpp-cache-dirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.concatMapStrings (model: "  mkdir -p '${hfModelDir model}'\n") (lib.unique cfg.models)}
    '';
  };
}
