{ lib, ... }:
with lib;
{
  environment = {
    memoryAllocator.provider = mkDefault "libc";
    variables.SCUDO_OPTIONS = mkDefault "ZeroContents=1";
  };

  security = {
    lockKernelModules = mkDefault true;
    protectKernelImage = mkDefault true;
    allowSimultaneousMultithreading = mkDefault false;
    forcePageTableIsolation = mkDefault true;
    apparmor = {
      enable = mkDefault true;
      killUnconfinedConfinables = mkDefault true;
    };
  };

  boot = {
    kernelParams = [
      # Slab/slub sanity checks, redzoning, and poisoning
      "slub_debug=FZP"

      # Overwrite free'd memory
      "page_poison=1"

      # Enable page allocator randomization
      "page_alloc.shuffle=1"
    ];

    blacklistedKernelModules = [
      # Virtualization
      "kvm"

      # Obscure network protocols
      "ax25"
      "netrom"
      "rose"

      # Old or rare or insufficiently audited filesystems
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hfs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "ntfs"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
      "ufs"
    ];

    kernel = {
      sysctl."kernel.ftrace_enabled" = mkDefault false;
      sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = mkDefault true;
    };
  };
}
