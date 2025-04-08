---
- name: Ensure tomcat user
  user:
    name: tomcat
    shell: /bin/false

- name: Create Tomcat install directory
  file:
    path: /opt/tomcat
    state: directory
    mode: '0755'

- name: Copy Tomcat archive
  copy:
    src: apache-tomcat-9.0.85-dev.tar.gz
    dest: /opt/tomcat/apache-tomcat.tar.gz

- name: Extract Tomcat
  unarchive:
    src: /opt/tomcat/apache-tomcat.tar.gz
    dest: /opt/tomcat
    remote_src: yes
    creates: /opt/tomcat/apache-tomcat-9.0.85

- name: Symlink to latest
  file:
    src: /opt/tomcat/apache-tomcat-9.0.85
    dest: /opt/tomcat/latest
    state: link
    force: yes

- name: Copy environment-specific keystore
  copy:
    src: dev-keystore.jks
    dest: /opt/tomcat/latest/conf/keystore.jks
    owner: tomcat
    group: tomcat
    mode: '0600'

- name: Deploy environment-specific server.xml
  template:
    src: server.xml.j2
    dest: /opt/tomcat/latest/conf/server.xml
    owner: tomcat
    group: tomcat
    mode: '0644'

- name: Copy Tomcat systemd unit file
  template:
    src: tomcat.service.j2
    dest: /etc/systemd/system/tomcat.service

- name: Reload systemd and start Tomcat
  systemd:
    name: tomcat
    daemon_reload: yes
    enabled: yes
    state: started