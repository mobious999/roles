---
- name: Ensure tomcat user
  ansible.builtin.user:
    name: tomcat
    shell: /bin/false

- name: Create Tomcat install directory
  ansible.builtin.file:
    path: /opt/tomcat
    state: directory
    mode: "0755"

- name: Copy Tomcat archive
  ansible.builtin.copy:
    src: apache-tomcat-9.0.85-dev.tar.gz
    dest: /opt/tomcat/apache-tomcat.tar.gz

- name: Extract Tomcat
  ansible.builtin.unarchive:
    src: /opt/tomcat/apache-tomcat.tar.gz
    dest: /opt/tomcat
    remote_src: true
    creates: /opt/tomcat/apache-tomcat-9.0.85

- name: Symlink to latest
  ansible.builtin.file:
    src: /opt/tomcat/apache-tomcat-9.0.85
    dest: /opt/tomcat/latest
    state: link
    force: true

- name: Copy environment-specific keystore
  ansible.builtin.copy:
    src: dev-keystore.jks
    dest: /opt/tomcat/latest/conf/keystore.jks
    owner: tomcat
    group: tomcat
    mode: "0600"

- name: Deploy environment-specific server.xml
  ansible.builtin.template:
    src: server.xml.j2
    dest: /opt/tomcat/latest/conf/server.xml
    owner: tomcat
    group: tomcat
    mode: "0644"

- name: Copy Tomcat systemd unit file
  ansible.builtin.template:
    src: tomcat.service.j2
    dest: /etc/systemd/system/tomcat.service

- name: Reload systemd and start Tomcat
  ansible.builtin.systemd:
    name: tomcat
    daemon_reload: true
    enabled: true
    state: started
