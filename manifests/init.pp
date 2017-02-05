<<<<<<< HEAD
class sysctl (Boolean $purge,
              Hash    $values,
              Boolean $symlink99,
              String  $sysctl_binary,
              Boolean $sysctl_dir,
              String  $sysctl_dir_path,
              String  $sysctl_dir_owner,
              String  $sysctl_dir_group,
              String  $sysctl_dir_mode) {

  $defaults = {
    sysctl_binary   => $sysctl_binary,
    sysctl_dir_path => $sysctl_dir_path,
=======
# Define: sysctl
#
# Manage sysctl variable values.
#
# Parameters:
#  $value:
#    The value for the sysctl parameter. Mandatory, unless $ensure is 'absent'.
#  $prefix:
#    Optional prefix for the sysctl.d file to be created. Default: none.
#  $ensure:
#    Whether the variable's value should be 'present' or 'absent'.
#    Defaults to 'present'.
#
# Sample Usage :
#  sysctl { 'net.ipv6.bindv6only': value => '1' }
#
define sysctl (
  $ensure  = undef,
  $value   = undef,
  $unless  = undef,
  $prefix  = undef,
  $suffix  = '.conf',
  $comment = undef,
  $content = undef,
  $source  = undef,
  $enforce = true,
) {

  include '::sysctl::base'

  # If we have a prefix, then add the dash to it
  if $prefix {
    $_sysctl_d_file = "${prefix}-${title}${suffix}"
  } else {
    $_sysctl_d_file = "${title}${suffix}"
  }

  # Some sysctl keys contain a slash, which is not valid in a filename.
  # Most common at those on VLANs: net.ipv4.conf.eth0/1.arp_accept = 0
  $sysctl_d_file = regsubst($_sysctl_d_file, '[/ ]', '_', 'G')

  # If we have an explicit content or source, use them
  if $content or $source {
    $file_content = $content
    $file_source = $source
  } else {
    $file_content = template("${module_name}/sysctl.d-file.erb")
    $file_source = undef
>>>>>>> cad7a8a4454888447d686259b270075b6e74afa3
  }
  create_resources(sysctl::configuration, $values, $defaults)

  if $sysctl_dir {
    # if we're purging we should also recurse
    $recurse = $purge
    file { $sysctl_dir_path:
      ensure  => directory,
      owner   => $sysctl_dir_owner,
      group   => $sysctl_dir_group,
      mode    => $sysctl_dir_mode,
      purge   => $purge,
      recurse => $recurse,
    }

<<<<<<< HEAD
    if $symlink99 and $sysctl_dir_path =~ /^\/etc\/[^\/]+$/ {
      file { "${sysctl_dir_path}/99-sysctl.conf":
        ensure => link,
        target => '../sysctl.conf',
=======
    # For the few original values from the main file
    exec { "update-sysctl.conf-${title}":
      command     => "sed -i -e 's#^${title} *=.*#${title} = ${value}#' /etc/sysctl.conf",
      path        => [ '/usr/sbin', '/sbin', '/usr/bin', '/bin' ],
      refreshonly => true,
      onlyif      => "grep -E '^${title} *=' /etc/sysctl.conf",
    }

    # Enforce configured value during each run (can't work with custom files)
    if $enforce and ! ( $content or $source ) {
      $qtitle = shellquote($title)
      # Value may contain '|' and others, we need to quote to be safe
      # Convert any numerical to expected string, 0 instead of '0' would fail
      # lint:ignore:only_variable_string Convert numerical to string
      $qvalue = shellquote("${value}")
      if $validate {
        $rvalue = shellquote("${unless}")
      } else {
        $rvalue = $qvalue
      }
      # lint:endignore
      exec { "enforce-sysctl-value-${qtitle}":
          unless  => "/usr/bin/test \"$(/sbin/sysctl -n ${qtitle})\" = \"$(/bin/echo -e '${rvalue}')\"",
          command => "/sbin/sysctl -w ${qtitle}=${qvalue}",
>>>>>>> cad7a8a4454888447d686259b270075b6e74afa3
      }
    }
  }
}
