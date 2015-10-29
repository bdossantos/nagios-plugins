#!/usr/bin/env bats

load test_helper

@test 'Test check_php_project_security_issue.sh without file flags provided' {
  run check_php_project_security_issue.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - path to composer.lock is not provided'
}

@test 'Test check_php_project_security_issue.sh with non existent composer.lock' {
  run check_php_project_security_issue.sh -f /nonexistentdirectory
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - composer.lock does not exist'
}

@test 'Test check_php_project_security_issue.sh with fake vulnerable composer.lock' {
  local curl_output='HTTP/1.1 100 Continue

HTTP/1.1 200 OK
Cache-Control: no-cache
Content-Type: text/plain; charset=UTF-8
Date: Fri, 16 Oct 2015 15:48:48 GMT
Server: nginx/1.4.6 (Ubuntu)
X-Alerts: 4
Content-Length: 1943
Connection: keep-alive

Security Report
===============

The checker detected 4 package(s) that have known* vulnerabilities in
your project. We recommend you to check the related security advisories
and upgrade these dependencies.

doctrine/annotations (v1.2.1)
-----------------------------

CVE-2015-5723: Security Misconfiguration Vulnerability in various Doctrine projects
               http://www.doctrine-project.org/2015/08/31/security_misconfiguration_vulnerability_in_various_doctrine_projects.html

doctrine/cache (v1.3.1)
-----------------------

CVE-2015-5723: Security Misconfiguration Vulnerability in various Doctrine projects
               http://www.doctrine-project.org/2015/08/31/security_misconfiguration_vulnerability_in_various_doctrine_projects.html

doctrine/common (v2.4.2)
------------------------

CVE-2015-5723: Security Misconfiguration Vulnerability in various Doctrine projects
               http://www.doctrine-project.org/2015/08/31/security_misconfiguration_vulnerability_in_various_doctrine_projects.html

monolog/monolog (1.10.0)
------------------------

xxx-xxxx-xxxx: Header injection in NativeMailerHandler
               https://github.com/Seldaek/monolog/pull/448#issuecomment-68208704

* Disclaimer: This checker can only detect vulnerabilities that are referenced
              in the SensioLabs security advisories database.'

  stub curl "$curl_output"
  run check_php_project_security_issue.sh -f /bin/ls
  [ "$status" -eq 1 ]
  echo "$output" | grep "WARNING - The checker detected 4 package(s) that have known vulnerabilities"
}
