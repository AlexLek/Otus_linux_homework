Name: otus_ps_ax
Version: 1
Release: 0
Summary: otus_ps
Group: Applications/File
License: BSD
# BuildRequires:  shc

%description
ps ax-like program written in bash

%prep

%install
mkdir -p %{buildroot}/usr/bin/
cp ../SOURCES/ps_ax.sh ./
%{__install} -D -m0755 ps_ax.sh ${RPM_BUILD_ROOT}/usr/bin/ps_ax.sh

%clean
rm -rf $RPM_BUILD_ROOT

%files
/usr/bin/ps_ax.sh

