# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-sailimgur

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Sailimgur is a simple Imgur app for Sailfish OS, powered by Qt, QML and JavaScript. It has a simple, native and easy-to-use UI.
Version:    0.1
Release:    1
Group:      Applications/Internet
License:    GPLv3
URL:        http://ruleoftech.com/lab/sailimgur
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-sailimgur.yaml
Requires:   sailfishsilica-qt5
Requires:   qt5-qtsvg-plugin-imageformat-svg
Requires:   qt5-plugin-imageformat-gif
Requires:   qt5-qtsvg
BuildRequires:  pkgconfig(Qt5Svg)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(sailfishapp)
BuildRequires:  desktop-file-utils

%description
Sailimgur is a simple Imgur app for Sailfish OS, powered by Qt, QML
and JavaScript. It has a simple, native and easy-to-use UI. At the moment it provides
basic anonymous user\u2019s imgur functionality like browsing and search.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}/qml
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
/usr/bin
/usr/share/harbour-sailimgur
/usr/share/applications
/usr/share/icons/hicolor/86x86/apps
# >> files
# << files
