# Erlang/OTP R16B02
# Version: 0.0.1
#
FROM ubuntu:latest
MAINTAINER darach@gmail.com

# Refresh apt
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git build-essential libncurses5-dev openssl libssl-dev curl openssh-server supervisor m4

# Setup SSH for remote access
RUN mkdir -p /var/run/sshd
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Download and install kerl from git
RUN mkdir -p /opt/erlang/
RUN curl -O https://raw.github.com/spawngrid/kerl/master/kerl && chmod a+x kerl
RUN mv kerl /opt/erlang/
RUN ln -s /opt/erlang/kerl /usr/local/bin/kerl
RUN kerl update releases

# Install Erlang/OTP R16B02
RUN KERL_CONFIGURE_OPTIONS=--enable-hipe kerl build R16B02 r16b02
RUN kerl install r16b02 /opt/erlang/r16b02

# Install Rebar
RUN cd /opt/erlang && git clone git://github.com/rebar/rebar.git
RUN cd /opt/erlang/rebar && ./bootstrap
RUN ln -s /opt/erlang/rebar/rebar /usr/local/bin/rebar

# Install relx
RUN cd /opt/erlang && git clone git://github.com/erlware/relx.git
RUN cd /opt/erlang/relx && ./make
RUN ln -s /opt/erlang/relx/relx /usr/local/bin/relx

CMD /opt/erlang/r16b02/bin/erl -sname test
