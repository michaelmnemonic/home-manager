{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.llama-cpp;
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
      };
      Install = {
        # user manager reaches default.target on the first login of the user
        # after boot — graphical, tty or ssh alike
        WantedBy = ["default.target"];
      };
    };
  };
}
