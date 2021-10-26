Name: runc
Version: %{_version}
Release: %{_release}
Summary: CLI tool for spawning and running containers according to the OCI specification
License: ASL 2.0
URL: https://opencontainers.org
Source0: %{name}-%{version}.tar.gz

Requires: container-selinux >= 2:2.74

%description
CLI tool for spawning and running containers according to the OCI specification

%prep
%setup

install -m 755 -d %{buildroot}%{_bindir}
install -p -m 755 -t %{buildroot}%{_bindir}/ runc

%files
%{_bindir}/runc