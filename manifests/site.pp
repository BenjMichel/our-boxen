require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include git
  include hub

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # Install cordova/ionic/gulp
  exec { "Cordova/ionic/gulp setup":
      command  => "sudo npm install -g cordova ionic gulp forever",
      path    => $path,
  }
}

# Android
include java
include eclipse::java
include android::sdk
include android::tools
include android::platform_tools
include android::21


# Mac osx settings
include osx::finder::unhide_library
include osx::finder::show_hidden_files
include osx::finder::show_all_filename_extensions
include osx::safari::enable_developer_mode


# atom
include atom
atom::package { 'linter': }
atom::theme { 'monokai': }


#sublime_text
include sublime_text

#install zsh and oh-my-zsh
include zsh
exec { "Zsh setup":
    command  => "curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh",
    path    => $path,
}

package { 'alfred': provider => 'brewcask' }
include chrome
include iterm2::stable
include keepassx
include mysql
include spectacle
include imagemagick
include mou
include mou::themes
