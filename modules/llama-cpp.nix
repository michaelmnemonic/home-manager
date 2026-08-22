{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.llama-cpp;
  # the -hf downloader (llama.cpp b10408) uses the huggingface_hub layout and
  # writes only inside the model directory (blobs/, snapshots/, refs/)
  hfModelDir = "${config.home.homeDirectory}/.cache/huggingface/hub/models--unsloth--Qwen3.8-27B-GGUF";
in {
  options.universe.llama-cpp = {
    enable = lib.mkEnableOption "Local LLM setup with llama.cpp";
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services."model-download" = {
      Unit = {
        Description = "Download LLM";
      };
      Service = {
        Type = "oneshot";
        # a potentionally long-running download must not be killed by the default 90s start timeout
        TimeoutStartSec = "infinity";
        RemainAfterExit = true;
        Slice = "background.slice";
        # llama-fit-params is not actually the correct tool, but llama.cpp does not provide a download-only tool
        ExecStart = "${pkgs.llama-cpp-vulkan}/bin/llama-fit-params -hf unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL";
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
        ReadWritePaths = [hfModelDir];
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
    };

    # pre-create the cache dir outside the sandbox: ReadWritePaths needs an
    # existing path and inside the unit the filesystem is read-only
    systemd.user.tmpfiles.rules = ["d ${hfModelDir} - - - - -"];
  };
}
