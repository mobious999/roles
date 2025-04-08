---
- name: Ensure tomcat user
  ansible.builtin.user:
    name: tomcat
    shell: /bin/false

- name: Deploy environment-specific server.xml
  ansible.builtin.template:
    src: server.xml.j2
    dest: /opt/tomcat/latest/conf/server.xml
    owner: tomcat
    group: tomcat
    mode: "0644"

- name: Reload systemd and start Tomcat
  ansible.builtin.systemd:
    name: tomcat
    daemon_reload: true
    enabled: true
    state: started
