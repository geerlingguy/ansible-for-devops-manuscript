# Changelog

This log will track changes between releases of the book. Until version 1.0, each release number correlates to the amount complete, so 'Version 0.75' equals 75% complete. After that, major version numbers track editions.

Hopefully these notes will help readers figure out what's changed since the last time they've downloaded the book.

## Current Version

  - No changes yet.

## Version 2.2 (2023-06-17)

  1. [#501](https://github.com/geerlingguy/ansible-for-devops/issues/501): Update remaining references to `yum` to use `dnf`, as `yum` is not used on any modern versions of RHEL.
  2. [#505](https://github.com/geerlingguy/ansible-for-devops/issues/505): Update package name for Debian/Ubuntu python software properties in chapter 1. (thanks to mbart13!)
  3. Removed deprecated `warn: false` option from Hubot example in chapter 15.
  4. Update all Vagrant VM host-only private network IP ranges to `192.168.56.0/21`.
  5. [#545](https://github.com/geerlingguy/ansible-for-devops/issues/545): Molecule CI installation requires molecule-plugins[docker] install in chapter 13.
  6. [#531](https://github.com/geerlingguy/ansible-for-devops/issues/531): When testing with Molecule, systemd in containers requires cgroupns mode set to host, and a read-write volume.
  7. [#542](https://github.com/geerlingguy/ansible-for-devops/issues/542): Fix various broken documentation links for Ansible Lint and Molecule (thanks to cristisulighetean!).
  8. [#539](https://github.com/geerlingguy/ansible-for-devops/issues/539): Fixed old reference to RHEL where Rocky Linux is being used (thanks to dropsignal!).
  9. [#526](https://github.com/geerlingguy/ansible-for-devops/pull/526) (see also [#484](https://github.com/geerlingguy/ansible-for-devops/pull/484)): Update Drupal example to PHP 8.2 and Drush 11 in chapter 4 (thanks to thescalaguy and Brain2life!).
  10. [#533](https://github.com/geerlingguy/ansible-for-devops/pull/533): Fix Kubernetes example using new role configuration variables for `control_plane` and `docker_packages` in chapter 16 (thanks to weshouman!).
  11. [#471](https://github.com/geerlingguy/ansible-for-devops/pull/471): Update Kubernetes example to 1.23 in chapter 16 (thanks to hippogriffin!).
  12. [#512](https://github.com/geerlingguy/ansible-for-devops/issues/512), [#500](https://github.com/geerlingguy/ansible-for-devops/issues/500), and [#491](https://github.com/geerlingguy/ansible-for-devops/issues/491): Fixed minor grammatical and URL errors in chapters 13, 2, and 14 (thanks to tphbrok, cateee, and daniel-robitaille!).
  13. [#498](https://github.com/geerlingguy/ansible-for-devops/issues/498): Remove unneccessary reference to a `command` that is no longer in use in Flask MySQL container configuration in chapter 15 (thanks to hubertbanas!).
  14. [#507](https://github.com/geerlingguy/ansible-for-devops/issues/507): Update `molecule init` command example for creating a new role in chapter 13 (thanks to elexwiz!).

## Version 2.1 (2022-04-15)

  1. [#314](https://github.com/geerlingguy/ansible-for-devops/issues/314): Explicitly define a `mode` in the `copy` task in the molecule example in chapter 13 so the copied web page is readable by the Apache web server.
  2. Install `molecule[docker]` in test dependency installation for GitHub Actions to ensure the Docker plugin is present.
  3. Bump `geerlingguy.elasticsearch` role version to `5.0.0` in chapter 9 requirements to incorporate an installation fix.
  4. [#393](https://github.com/geerlingguy/ansible-for-devops/issues/393): Fix molecule test failing in chapter 13 due to Ansible not being installed.
  5. [#403](https://github.com/geerlingguy/ansible-for-devops/issues/403): Update Node.js to version 14 in Hubot Docker example to fix `yo` compatibility issue.
  6. [#442](https://github.com/geerlingguy/ansible-for-devops/issues/442): Fix incorrect use of the term 'play' in Node.js app example.
  7. [#447](https://github.com/geerlingguy/ansible-for-devops/issues/447): Adjust `php-apcu` package to `php7.4-apcu` so install succeeds without PHP CLI version going to `8.1`. (thanks to MrPOC!)
  8. [#461](https://github.com/geerlingguy/ansible-for-devops/issues/461): Add `mysql_replication_role` to `lamp_db` hosts in LAMP server Vagrant inventory file in chapter 9. (thanks to MrPOC!)
  9. [#445](https://github.com/geerlingguy/ansible-for-devops/issues/445): Update references to now-mothballed service Server Check.in in chapters 3, 5, 8, and 10. (thanks to fosstube!)
  10. [#436](https://github.com/geerlingguy/ansible-for-devops/issues/436): Fix invalid line reference in a note in chapter 5.
  11. Adjusted Molecule example in chapter 13 to use FQCNs to avoid adding extra ansible-lint configuration.
  12. [#225](https://github.com/geerlingguy/ansible-for-devops/pull/225): Move success message to node.js app's `listen` callback in chapter 4. (thanks to mkrawczuk!)
  13. [#466](https://github.com/geerlingguy/ansible-for-devops/issues/466): Fix duplicate 'the' in a line in chapter 3. (thanks to @MrEddX!)
  14. [#453](https://github.com/geerlingguy/ansible-for-devops/issues/453): Fix various references (especially in chapters 1-6, 11, and 13) to CentOS 8 that are now using Rocky Linux 8 because CentOS 8 is no more.
  15. [#463](https://github.com/geerlingguy/ansible-for-devops/issues/463): Fixed link to Ansible's docs for 'magic variables' in chapter 5. (thanks to HonkinWaffles!)
  16. [#425](https://github.com/geerlingguy/ansible-for-devops/issues/425): Fixed node.js forever example in chapter 4 to use Rocky Linux 8 and new path plus updated Remi repository URLs. (thanks to varunvats and kenhia!)
  17. [#408](https://github.com/geerlingguy/ansible-for-devops/issues/408): Fixed broken link to Ansible's built-in user module documentation. (thanks to CodingIsLove!)
  18. [#439](https://github.com/geerlingguy/ansible-for-devops/issues/439): Typo fix: s/`linefile`/`lineinfile` in chapter 11. (thanks to clevengr!)
  19. [#438](https://github.com/geerlingguy/ansible-for-devops/issues/438): Fix erroneous reference to `provisioning.yml` playbook (that doesn't exist) in chapter 10. (thanks to clevengr!)
  20. [#437](https://github.com/geerlingguy/ansible-for-devops/issues/437): Grammar fix: missing the word 'use' in a sentence in chapter 9. (thanks to clevengr!)
  21. [#399](https://github.com/geerlingguy/ansible-for-devops/issues/399): Grammar fix: do you and not to you in chapter 9. (thanks to jlmuir!)
  22. [#398](https://github.com/geerlingguy/ansible-for-devops/issues/398): Finish updating all references to 'Mac OS X' and 'OS X' to just 'macOS'. (thanks to jlmuir!)
  23. [#347](https://github.com/geerlingguy/ansible-for-devops/issues/347): I don't think I'll ever use 'it's' correctly. Fixing many instances of it's where it shouldn't be so possessive. (thanks to David-Gil!)
  24. [#395](https://github.com/geerlingguy/ansible-for-devops/issues/395): Fix an instance of 'the' being used twice in the same sentence in a very improper manner. Grammar gets me again. (thanks to geerew!)
  25. [#460](https://github.com/geerlingguy/ansible-for-devops/issues/460): 256 MB of RAM was not enough for anybody. Bumped limits for www servers in chapter 10 and node.js servers in chapter 9 to 512 MB of RAM. (thanks to MrPOC!)
  26. [#319](https://github.com/geerlingguy/ansible-for-devops/issues/319): Fixed an extra dangling double quote in chapter 5. (thanks to gpatkinson!)
  27. [#324](https://github.com/geerlingguy/ansible-for-devops/issues/324): Fixed an extra 'a' in chapter 5. I need to do better there. (thanks to braykov!)
  28. [#330](https://github.com/geerlingguy/ansible-for-devops/issues/330): Fix example path to an `update.sh` script in chapter 3. (thanks to grendelson!)
  29. [#333](https://github.com/geerlingguy/ansible-for-devops/issues/333): Fixed a few lingering `ntpd` references that should be `chronyd` in chapter 3. (thanks to rpappalax!)
  30. [#351](https://github.com/geerlingguy/ansible-for-devops/issues/351): Fixed typo: 'explicitly' and not 'explictly'. (thanks to Octobug!)
  31. [#380](https://github.com/geerlingguy/ansible-for-devops/issues/380): Use case-insensitive `grep` when searching for 'cookie' string in output in load balancer example in chapter 10. (thanks to typ-ex!)
  32. [#456](https://github.com/geerlingguy/ansible-for-devops/issues/456): Fix 'is blue' assertion for string comparison to use `==` in chapter 7 filter plugin example. (thanks to MrPOC!)
  33. [#337](https://github.com/geerlingguy/ansible-for-devops/issues/337): Use `pip3` when installing `django` in chapter 3 example by setting the correct options. (thanks to doug-rosser!)
  34. [#429](https://github.com/geerlingguy/ansible-for-devops/issues/429): Improve Rails deployment example in chapter 10 (note: it still isn't working correctly right now due to various issues stemming from dependency hell).

## Version 2.0 (2020-07-05)

  1. Adjust apt `name` parameter to take list of packages to ensure are removed in example in chapter 10.
  2. Fix some confusing language around plays and tasks in 'use `sudo`' section in chapter 10.
  3. [#280](https://github.com/geerlingguy/ansible-for-devops/issues/280): Adjust json line in Python dynamic inventory file in chapter 7 to be compatible with Python 3.
  4. [#281](https://github.com/geerlingguy/ansible-for-devops/issues/281): Simplify imports in Python dynamic inventory file in chapter 7.
  5. [#202](https://github.com/geerlingguy/ansible-for-devops/issues/202): Add new chapter 7 on 'Collections' and increment existing chapters 7-15 to chapters 8-16.
  6. [#206](https://github.com/geerlingguy/ansible-for-devops/pull/206): Remove Vagrantfile `compatibility_mode` setting in chapter 9 ELK example since it's not as important with Vagrant 2.2.8 and later.
  7. [#284](https://github.com/geerlingguy/ansible-for-devops/issues/284): Fixed errant 'playback' term in chapter 6, replaced with 'playbook' (thanks to claycooper!).
  8. [#273](https://github.com/geerlingguy/ansible-for-devops/issues/273): Added validate option for SSH config in chapter 11.
  9. [#271](https://github.com/geerlingguy/ansible-for-devops/issues/271): Add note about `seport` configuration required for SSH example in chapter 11 so SELinux allows SSH to run from alternate port on RHEL or CentOS.
  10. [#219](https://github.com/geerlingguy/ansible-for-devops/issues/219): Don't recommend using `sudo` when installing Ansible or Boto via `pip` in chapters 1 and 8.
  11. [#249](https://github.com/geerlingguy/ansible-for-devops/issues/249): Update Helm section in chapter 16 to use new Helm v3 modules in `community.kubernetes` collection.
  12. [#250](https://github.com/geerlingguy/ansible-for-devops/issues/250): Incorpoate latest Ansible best practices for choosing dependencies and using project-local dependencies in appendix B.
  13. [#278](https://github.com/geerlingguy/ansible-for-devops/issues/278): Updated broken links to various Vagrant resources in chapter 2 (thanks to vonDowntown!).
  14. [#293](https://github.com/geerlingguy/ansible-for-devops/issues/293): Update variable information in chapter 5 to incorporate the ability to start variable names with underscores (`_`), and a mention of the convention of using that for private role variables (thanks to kolewu!).
  15. [#212](https://github.com/geerlingguy/ansible-for-devops/issues/212): Completely rewrite the Tower and AWX section in chapter 12 with new content based on running AWX via Docker Compose.
  16. [#295](https://github.com/geerlingguy/ansible-for-devops/issues/295): Update all examples using Ubuntu 16.04 or 18.04 to Ubuntu 20.04.
  17. [#299](https://github.com/geerlingguy/ansible-for-devops/issues/299): Move Gluster example code in chapter 9 to Ansible for DevOps GitHub repository and update to Ubuntu 20.04.
  18. [#301](https://github.com/geerlingguy/ansible-for-devops/issues/301): Move Docker Flask app example from chapter 15 into Ansible for DevOps GitHub repository and update everything to Ubuntu 20.04.
  19. [#298](https://github.com/geerlingguy/ansible-for-devops/issues/298): Update syntax of role requirements files to use `name` instead of `src` and use `roles` keyword for better organization.
  20. [#93](https://github.com/geerlingguy/ansible-for-devops/issues/93): Assume Python 3 by default and remove extra python raw module install step in Let's Encrypt example.
  21. [#187](https://github.com/geerlingguy/ansible-for-devops/issues/187): Fix php roles to work correctly out of the box in Debian Buster and Ubuntu 20.04.
  22. [#191](https://github.com/geerlingguy/ansible-for-devops/issues/191): Update section on `fail` vs. `assert` in chapter 13 to note the difference in playbook output between the two.
  23. [#195](https://github.com/geerlingguy/ansible-for-devops/issues/195): Add warning about `NOPASSWD` use in sudoers file in chapter 11.
  24. [#229](https://github.com/geerlingguy/ansible-for-devops/issues/229): Update DigitalOcean dynamic inventory example in chapter 8 to use newer DigitalOcean modules. Also update DigitalOcean provisioner example in chapter 9 to use newer DigitalOcean modules.
  25. [#304](https://github.com/geerlingguy/ansible-for-devops/issues/304): Update AWS lamp-infrastructure example in chapter 9 to use newer image and work better with SELinux enabled.
  26. [#239](https://github.com/geerlingguy/ansible-for-devops/issues/239): Make sure apt caches are updated in HAProxy load balancer deployment example in chapter 10 (thanks to searsaw and MacFlurry!).
  27. [#256](https://github.com/geerlingguy/ansible-for-devops/issues/256): Update Ansible Vault example in chapter 5 to be able to run locally by default.
  28. [#258](https://github.com/geerlingguy/ansible-for-devops/issues/258): Add `geerlingguy.pip` role dependency to ELK server example in chapter 9 and increase VirtualBox VM RAM allocation from 2 to 4 GB (thanks to mandrews4!).
  29. [#259](https://github.com/geerlingguy/ansible-for-devops/issues/259): Update chapter 10 Rails deployment demo Vagrantfile for better WSL compatibility (thanks to mandrews4!).
  30. [#288](https://github.com/geerlingguy/ansible-for-devops/issues/288): Fixed the word 'the' which should be 'then' in the 'Configuring a firewall' section of chapter 11 (thanks to claycooper!).
  31. [#283](https://github.com/geerlingguy/ansible-for-devops/issues/283): Adjusted a few things in chapter 11 for compatibility with CentOS 8 security configuration, and added link to new [security examples](https://github.com/geerlingguy/ansible-for-devops/tree/master/security) included in the book's repository (thanks to fama!).
  32. [#286](https://github.com/geerlingguy/ansible-for-devops/issues/286): Fix zero-downtime deployment example Vagrantfile comment in chapter 10 - it said 'four' servers when 'three' were actually defined (thanks to claycooper!).
  33. [#277](https://github.com/geerlingguy/ansible-for-devops/issues/277): Fix filename in chapter 11 apt autoupdates example; was `10periodic`, now `20auto-upgrades` (thanks to glillico!).
  34. [#303](https://github.com/geerlingguy/ansible-for-devops/issues/303): Update chapter 8 and chapter 9 AWS inventory examples to use the `aws_ec2` inventory plugin.
  35. [#260](https://github.com/geerlingguy/ansible-for-devops/issues/260): Default to using inventory files in projects, rather than the default global `/etc/ansible/hosts` file, in chapters 1, 2, 3, and 8.
  36. [#307](https://github.com/geerlingguy/ansible-for-devops/issues/307): Update Apache Solr version in chapter 4 example to 8.6.0.
  37. [#308](https://github.com/geerlingguy/ansible-for-devops/issues/308): Update Drupal example in chapter 4 to install Drush 10 and Drupal 9, using new Composer-based setup.
  38. [#306](https://github.com/geerlingguy/ansible-for-devops/pull/306): Fix capitalization of 'Chrony'. It should be 'chrony' (thanks to Redmar-van-den-Berg).
  39. [#221](https://github.com/geerlingguy/ansible-for-devops/issues/221): Update multi-server orchestration example in chapter 3 to use on CentOS 8, Python 3, and Django 3. Also add automated testing of most of the examples in chapter 3 against test Docker containers.

## Version 1.23 (2020-05-13)

  1. [#101](https://github.com/geerlingguy/ansible-for-devops/issues/101): Describe a modern Ansible testing workflow by move testing content into dedicated chapter, chapter 12, covering `yamllint`, `ansible-lint`, Molecule, and other testing strategies. Also, bump former chapters 12-14 into chapters 13-15.
  2. [#246](https://github.com/geerlingguy/ansible-for-devops/issues/246): Update formatting of code examples.
  3. [#245](https://github.com/geerlingguy/ansible-for-devops/issues/245): Fix dynamic inclusion of variable files based on `ansible_os_family` in chapter 5.
  4. [#220](https://github.com/geerlingguy/ansible-for-devops/issues/220): Update 'Your first Ansible playbook' example in chapter 2 to use `chrony` instead of `ntp`, and highlight Ansible's syntax possibilities.
  5. Updated list of tested platforms in Travis CI testing example in chapter 11.
  6. Mention `ansible-bender` alongside mention of legacy Ansible Container software in Docker example in chapter 13.
  7. [#101](https://github.com/geerlingguy/ansible-for-devops/issues/101): Describe a modern Ansible testing workflow by move testing content into dedicated chapter, chapter 12, covering `yamllint`, `ansible-lint`, Molecule, and other testing strategies. Also, bump former chapters 12-14 into chapters 13-15.
  8. [#238](https://github.com/geerlingguy/ansible-for-devops/pull/238): Add `acl` to list of installed dependencies in Drupal installation example to fix permissions error during Drupal installation Composer tasks (thanks to misse!).
  9. [#222](https://github.com/geerlingguy/ansible-for-devops/issues/222): Fix confusing use of playbook instead of 'play' in chapter 4 (thanks to mkrawczuk!).
  10. [#223](https://github.com/geerlingguy/ansible-for-devops/issues/223): Remove now-removed `--become-user` CLI shortcut `-U` from example in chapter 4 (thanks to mkrawczuk!).
  11. [#224](https://github.com/geerlingguy/ansible-for-devops/issues/224): Remove warning about `lineinfile` not being able to validate sudoers file with `visudo` (thanks to lustoerk!).
  12. [#226](https://github.com/geerlingguy/ansible-for-devops/issues/226): Mention the default login credentials in chapter 11's Jenkins example (thanks to lustoerk!).
  13. [#227](https://github.com/geerlingguy/ansible-for-devops/issues/227): Start using `ansible-galaxy role` instead of bare `ansible-galaxy` when running role-related commands in chapter 6, in preparation for Ansible 2.10 and beyond (thanks to thescouser89!).
  14. [#230](https://github.com/geerlingguy/ansible-for-devops/issues/230): Replace instances of `ansible_ssh_user` with `ansible_user`.
  15. [#247](https://github.com/geerlingguy/ansible-for-devops/issues/247): Mention 'The Bullhorn' newsletter as a resource for keeping up with the Ansible community in the introduction.
  16. [#251](https://github.com/geerlingguy/ansible-for-devops/issues/251): Removed a wayward parenthesis in chapter 4 (thanks to rechvs!).
  17. [#254](https://github.com/geerlingguy/ansible-for-devops/issues/254): Fixed path to ELK `main.yml` playbook in example in chapter 8 (thanks to mandrews4!).
  18. Updated book version to 1.23, set latest Ansible version to 2.9.9.

## Version 1.22 (2020-03-20)

  1. [#211](https://github.com/geerlingguy/ansible-for-devops/issues/211): Fixed typo with duplicate 'on's in chapter 13 Docker example (thanks to @kevinbowen777!).
  2. [#210](https://github.com/geerlingguy/ansible-for-devops/issues/210): Updated automatic updates example in chapter 10 to use more modern unattended-upgrades configuration files (thanks to @kevinbowen777!).
  3. Added note about use of `dnf-automatic` instead of `yum-cron` for RHEL and CentOS 8 and the latest versions of Fedora in chapter 10 automatic updates section.
  4. [#209](https://github.com/geerlingguy/ansible-for-devops/issues/209): Don't use `sudo` when running `ansible-galaxy install` in chapter 9 multi-server deployment example (thanks to @kevinbowen777!).
  5. [#208](https://github.com/geerlingguy/ansible-for-devops/issues/208): Clean up playbook variables section in chapter 5 and clarify use of Facter and Ohai if they are present on the systems being managed.
  6. [#203](https://github.com/geerlingguy/ansible-for-devops/issues/203): Fixed two clumsy sentences in GlusterFS example in chapter 8 (thanks to @kevinbowen777!).
  7. [#207](https://github.com/geerlingguy/ansible-for-devops/issues/207): Clarified reasoning behind `pre_tasks` section in relation to the rest of a play in chapter 4 (thanks to @gaddman!).
  8. [#213](https://github.com/geerlingguy/ansible-for-devops/issues/213): Fixed paragraph describing non-existent tasks in Drupal example in chapter 4 (thanks to @dirks!).
  9. [#216](https://github.com/geerlingguy/ansible-for-devops/issues/216): Fixed use of deprecated `-s` in ad hoc tasks in Gluster example (thanks to @hatchmount77!).
  10. [#217](https://github.com/geerlingguy/ansible-for-devops/issues/217): Fixed `free -h` command and grammar in chapter 1 ad-hoc examples (thanks to @ew0k!).
  11. [#215](https://github.com/geerlingguy/ansible-for-devops/issues/215): Fixed three grammar issues (well two really, one wasn't a problem) identified by KDP's quality scan.
  12. Updated book version to 1.22, set latest Ansible version to 2.9.5.

## Version 1.21 (2020-01-16)

  1. Fixed typo with duplicate 'to's in Foreword (thanks to @jmowens!).
  2. Fixed role `requirements.yml` file example for git role source (it was using 1.x parameters and didn't work in 2.x - thanks to @7php!).
  3. Fixed typo in chapter 13 regarding Ubuntu version used for Flask app (thanks to Kasia Gauza!).
  4. Fixed incorrect `--remote-user` flag for `ansible-playbook` in chapter 4's 'user options' section (thanks to peurKe!).
  5. Fixed order of first two paragraphs in chapter 4's extra yum repository example (thanks to rusnino!)
  6. Fixed incorrect `ansible` command to install `git` if missing in chapter 3 version control example (thanks to rusnino!).
  7. Removed extra mention of `with_items` from chapter 4's Apache installation example since it uses a list passed to the yum module directly (thanks to guntbert!).
  8. Remove confusion in chapter 4 `with_items` example by formatting the dict in a list using YAML instead of JSON (thanks to dirks!).
  9. Removed unused `restart solr` handler from example in chapter 4 because YAGNI (thanks to dirks!).
  10. Removed extra `%` in regexp for sudo example in chapter 10's 'use sudo' section (thanks to danmichaelo!).
  11. [#196](https://github.com/geerlingguy/ansible-for-devops/issues/196): Rebuilt and rewrote ELK example in chapter 8 to use modern versions of the ELK stack components and Filebeat.
  12. [#197](https://github.com/geerlingguy/ansible-for-devops/issues/197): The Jinja2 project was renamed to 'Jinja', so references in the text were updated accordingly.
  13. [#198](https://github.com/geerlingguy/ansible-for-devops/issues/198): Update chapter 4 Drupal playbook example to use Drupal 8.8.x.
  14. [#189](https://github.com/geerlingguy/ansible-for-devops/issues/189): Update molecule project GitHub URL in chapter 11 (thanks to apatard!).
  15. [#194](https://github.com/geerlingguy/ansible-for-devops/issues/194): Fixed link to AWS dynamic inventory script in chapter 7 (thanks to @goagex!).
  16. [#193](https://github.com/geerlingguy/ansible-for-devops/pull/193): Fixed usage of `ansible_kubectl_namespace` in `kubectl` connection example in chapter 14 (thanks to SamyCoenen!).
  17. [#192](https://github.com/geerlingguy/ansible-for-devops/issues/192): Fix idempotence of Drupal playbooks by ensuring codebase is owned by the Apache user, `www-data` (thanks in part to arashpath!).
  18. [#190](https://github.com/geerlingguy/ansible-for-devops/pull/190): Fixed order of EPEL repo installation in Node.js example in chapter 4 to be more technically correct (thanks to arashpath!).
  19. [#184](https://github.com/geerlingguy/ansible-for-devops/issues/184): Update Node.js shell script install example in chapter 4 with newer Remi repo URL and more correct ordering (thanks to peurKe and arashpath!).
  20. Updated book version to 1.21, set latest Ansible version to 2.9.5.

## Version 1.20 (2019-09-05)

  1. Updated some outdated links in introduction.
  2. Updated Express app version requirement in chapter 4 since 3.x is no longer supported.
  3. Fixed Ubuntu LTS version reference in chapter 4 LAMP example (thanks to @deoren!).
  4. Adjust apt module usage in chapter 4 LAMP example to fix deprecation warning (thanks to dglinder!).
  5. Fixed 'capcacity' typo in chapter 9 (thanks to Ruan A!).
  6. Completely refactored and updated Ruby on Rails deployment example in chapter 9 to use the latest OS and Ruby versions.
  7. Fixed some ham-fisted typos regarding Ansible, Inc. in the Introduction (thanks to @eCubeH!).
  8. Fix yet another instance of _it's_ which should be _its_ in chapter 5 (thanks to @erikj!).
  9. Fix shell examples in chapter 4 to use https instead of http (thanks to @erikj!).
  10. Use CentOS 7 in LAMP infrastructure example in chapter 8 (upgrade from CentOS 6).
  11. Update the Kubernetes example in chapter 14 to use Kubernetes 1.13 instead of 1.11 (thanks for identifying the issue @srufle!).
  12. Update Windows Vagrant and VirtualBox-based Ansible example in appendix a.
  13. Update deployments behind a load balancer example to use Ubuntu 18.04 in chapter 9.
  14. Update rolling deployments example to use Ubuntu 18.04 in chapter 9.
  15. Update Gluster example in chapter 8 to use Ubuntu 18.04 (thanks for identifying the issue @dino-github!).
  16. Add apt cache update task in chapter 9 rolling deployment example.
  17. Update task name for Tiller ServiceAccount in chapter 14 (thanks to Richard D!).
  18. Added note about ssh service name difference in example in chapter 10 (thanks to @stegr04!).
  19. Fixed Dynamic includes example file path in chapter 6 (thanks to @sandipb!).
  20. Added note about RHEL servers requiring additional `geerlingguy.epel` repo added for 9-line LAMP example in chapter 6 (thanks to @sandipb!).
  21. Completed section on obtaining Let's Encrypt certificates in chapter 12.
  22. Completed section on Nginx HTTPS proxying for HTTP applications in chapter 12.
  23. Updated Kubernetes version in chapter 14 example to 1.13.8 (thanks to @torenware!).
  24. Fixed a typo in chapter 2 (thanks to @atatevyan!).
  25. Fixed a missing end parentheses in chapter 4 (thanks to @VoidSignal!).
  26. Fixed multiple typos in chapters 7, 10, and 13 (thanks to @erikj!).
  27. Removed section on Accelrated mode in chapter 3 since it is no longer in existence (thanks to @evilhamsterman!).
  28. Clarified explanation of `vagrant up` and `vagrant provision` in chapter 2 (thanks to @charlieok!).
  29. Fixed other typos in chapters 1 and 2 (thanks to @charlieok!).
  30. Rewrote section on backgrounded asynchronous tasks, since polling has been broken since Ansible 2.0 (see [Issue #91](https://github.com/geerlingguy/ansible-for-devops/issues/91)).
  31. Fixed issue with retrieving nodePort from K8s cluster in chapter 14; switched from `k8s` to `k8s_info` module.
  32. Fixed minor typos in chapter 4, 6, 8, 9, and 10 (thanks to @jlmuir!).
  33. Fixed text regarding `include_tasks` and dynamic filenames in chapter 6 (thanks to @atatevyan!).
  34. Rewrite Docker Flask app example in chapter 13 to fix many broken things.
  35. Fixed deprecation notices caused by outdated examples in chapters 4, 7 and 13 (refer to issue #165).
  36. Fixed `state=link` confusion with ownership in chapter 3 (thanks to @vedvyas and Jeffrey 'jf' Lim!).
  37. Fixed deprecated `with_items` use with `yum` module in playbook idempotence example in chapter 4 (thanks to Jeffrey 'jf' Lim!).
  38. Fixed line numbering issue in node.js example in chapter 4 (thanks to Jeffrey 'jf' Lim!).
  39. Removed a few uses of `shell` module where not required in chapter 4 Drupal example (thanks to Jeffrey 'jf' Lim!).
  40. Updated Solr version in chapter 4 example to 8.2.0, and switched from `shell` to `command` for Solr install command (thanks to Jeffrey 'jf' Lim!).
  41. Switch from deprecated `copy: no` to `remote_src: true` usage in Solr example in chapter 4 (thanks to Jeffrey 'jf' Lim!).
  42. Updated book version to 1.20, set latest Ansible version to 2.8.4.

## Version 1.17 (2018-09-12)

  1. Updated Mac Ansible install instructions in chapter 1 (thanks to @vtraida!).
  2. Install Django version 1.x in chapter 3 example so it works with CentOS 7 out of the box (thanks to @everett-toews!).
  3. Tidied up ntpd service detection in example script in chapter 2 (thanks to Germain G!).
  4. Added more detailed current book publication stats in the preface (thanks to vinceskahan!).
  5. Removed mention of nonexistent `host_vars/all` inventory file in chapter 5 (thanks to @vaygr!).
  6. Updated link to Hashicorp's Vagrant box directory in chapter 2 (thanks to bryankennedy!).
  7. Added note about overcoming host key prompts when connecting to a server for the first time in chapter 3 (thanks to i-zu!).
  8. Mention `.bash_login` instead of repeating `.bash_profile` ad nauseam in chapter 5 (thanks to jdavid5815!).
  9. Fixed a typo in chapter 6 (thanks to jdavid5815!).
  10. Add `become: yes` to playbook example for Node.js App deployment in chapter 4 (thanks to krystan!).
  11. Fixed a typo in chapter 5 (thanks to nkabir!).
  12. Use https for Drupal.org git repository in chapter 4 and chapter 6 includes examples (thanks to dglinder!).
  13. Add chapter 13, dedicated to Docker and Ansible. Move Docker content from chapter 8 into this new chapter.
  14. Updated cowsay quote in chapter 8 (moved it's cowsay to chapter 13).
  15. Add Hubot Slack bot example in chapter 13.
  16. Add chapter 14, dedicated to Kubernetes and Ansible.
  17. Fixed typo in MySQL example in chapter 8 (thanks to ck05!).
  18. Install dependency `libssl-dev` to ensure self-signed cert example works in chapter 12.
  19. Fix spelling errors in chapter 13.
  20. Standardize on spelling 'web server' instead of 'webserver'.
  21. Adjusted Remi's repo and GPG key URLs to use https (thanks to scottdavis99!).

## Version 1.16 (2018-03-15)

  1. Updated example `Dockerfile`s; removed usage of deprecated `MAINTAINER` property.
  2. Updated HAProxy example in chapter 9 to use `with_items: "{{ variable }}"` syntax.
  3. Updated Includes and Role vars examples in chapter 6 to use `with_items: "{{ variable }}"` syntax.
  4. Fixed with_items and with_indexed_items syntax in chapter 8 AWS LAMP infrastructure example (thanks to @Ben K!).
  5. Switch the `memcached_listen_ip` to `0.0.0.0` in chapter 8 LAMP infrastructure example so Memcached starts more reliably.
  6. Use 64-bit CentOS image in chapter 8 DigitalOcean LAMP infrastructure example (thanks to @mattjmcnaughton!).
  7. Updated URLs for Cobbler and Func in introduction (thanks to @codeyy!).
  8. Added chapter 12: "Automating HTTPS and TLS Certificates".
  9. Switch from using '.dev' to '.test' for local domains.
  10. Switch from using `ansible.sudo` to `ansible.become` in Vagrantfiles.
  11. Fix typo in chapter 11 (double 'a's) (thanks to bngsudheer!).
  12. Switch incorrect usage of 'most any' to 'almost any' in chapter 11 (thanks to @Gogowitsch!).
  13. Updated now-deprecated use of `include:` to `import_tasks:` or `include_tasks:`.
  14. Fixed three typos spotted by Amazon Kindle's AI bot that loves good spelling.
  15. Updated DigitalOcean provisioning example in chapter 8 to work with new size and image slugs.
  16. Updated Docker Flask example in chapter 8 to use Ubuntu 16.04 and library MySQL image.
  17. Updated use of `include:` to `import_playbook:` in examples in chapter 9.
  18. Updated DigitalOcean playbook to use new size and image slugs in chapter 7.

## Version 1.15 (2017-06-01)

  1. Updated the `creates` examples in chapter 4's Drupal example to be Composer-specific (thanks to @santisaez!).
  2. Updated the Drupal example to default to Drupal `8.2.x` (was `8.1.x`).
  3. Updated the Drupal example to use PHP 7.1 instead of 7.0.
  4. Updated the Drupal example to install Ondrej's updated and maintained PPA (thanks to @jonleibowitz!).
  5. Rewrote appendix a in light of the Windows 10 WSL and Bash on Ubuntu on Windows.
  6. Updated documentation to switch from deprecated `always_run: yes` to `check_mode: no`.
  7. Fixed Node.js rolling deployment example's `forever` usage in chapter 9 (thanks to @mattjmcnaughton!).
  8. Fixed bare variable warning for `environment` setting in chapter 9 Rails deployment playbook.
  9. Fixed Drupal playbook example in chapter 4; drush git checkout is now `version: 8.x` (thanks to @cwardgar, @rschmidtz, and @scarroy!).
  10. Fixed Docker example in chapter 8; `docker` module is deprecated, use the `docker_container` module instead.
  11. Fixed Drupal playbook includes example in chapter 6 (to match tasks from chapter 4 Drupal playbook) (thanks to @cwardgar!).
  12. Fixed reference to `docker-py` Pip library (now it's just `docker`) in chapter 8.
  13. Switched Jenkins example in chapter 11 to use Ubuntu 16.04 since CentOS 7 doesn't include Java 8 by default.
  14. Removed deprecated `{{ var }}` syntax from Node.js `when` clauses in examples in chapters 4 and 5.
  15. Fixed links to various Ansible Galaxy roles that were 404'ing.
  16. Updated Solr example in chapter 4 to use Solr 6.5.1.

## Version 1.14 (2016-11-23)

  1. Fixed typo in Node.js app section in chapter 4 (thanks to @guntbert!).
  2. In chapter 1, when installing Ansible on Mac via `pip`, don't use `sudo` (thanks to @rdonkin!).
  3. In chapter 4, an incorrect use of 'play' was replaced with 'task' in 'Power Plays' (thanks to @guntbert!).
  4. In chapters 3, 8, and 11, updated multiple instances of `-s` and `--sudo` in ad-hoc commands; should use `-b` and `--become` instead (thanks to @charleshepner!).
  5. Fixed typo: `s/infrasturcture/infrastructure` in chapter 9 (thanks to /u/levelupirl!).
  6. Rewrote entire Travis CI testing section in chapter 11 to use Docker for multi-platform tests.
  7. Added a note on SSH key IDs in chapter 7 and chapter 8 DigitalOcean examples (thanks to @tychay!).
  8. Fixed playbook name (was `do_test`, should be `provision`) in chapter 7 (thanks to @tychay!).
  9. Removed deprecated include variables usage example in chapter 6 in 'Includes' section (thanks to @williamt!).
  10. Added `unzip` dependency to Drupal example in chapter 4 (thanks to @wurzeldub!).

## Version 1.13 (2016-07-21)
  1. Updated DigitalOcean provisioning and inventory example in chapter 7.
  2. Updated DigitalOcean LAMP infrastructure provisioning example for v2 API in chapter 8.

## Version 1.12 (2016-07-09)

  1. Updated links to resources in Introduction, removed link to defunct Ansible Weekly newsletter.
  2. Fixed grammar mistakes in parts of the Foreword, Preface, and Introduction.
  3. Updated URLs to Vagrant resources in chapter 2.
  4. Added note about cleaning up example VM with `vagrant destroy` in chapter 2.
  5. Use linked clones in Vagrantfiles for faster build in chapters 3, 7, 8, 9, and 11.
  6. Added 'Manage packages' section in chapter 3.
  7. Switched usage of `sudo` and `sudo`-related CLI options to `become` lingo for 1.9+.
  8. Updated Drupal playbook example in chapter 4 to use Ubuntu 16.04 LTS and PHP 7.
  9. Updated Apache Solr playbook example in chapter 4 to use Ubuntu 16.04 LTS and Solr 6.1.0.
  10. Added example images of running Drupal and Apache Solr home pages in chapter 4.

## Version 1.11 (2016-07-04)

  1. Fixed Apache Solr mirror URL in chapter 4 (thanks to @daniloradenovic!).
  2. Updated Drupal example in chapter 4 for Ubuntu 14.04 and PHP 5.6 (thanks to @e1nh4nd3r!).
  3. Updated Node.js app server example in chapter 4 to use `yum` for Remi repo install.
  4. Update a few lines for Ansible 2.1.x support.
  5. Fixed 'Variable Precedence' section in chapter 5 for Ansible 2.x (thanks to @daniel!).
  6. Updated misspellings of 'RedHat' to 'Red Hat' or 'RHEL' when referring to the OS.

## Version 1.1 (2016-03-06)

  1. Fixed sentence describing use of `serial` in chapter 9 (thanks to @devtux_at!).
  2. Fixed sentence describing SSH password behavior in chapter 10 (thanks to @sillygwailo!).
  3. Fixed private key destination path in example in chapter 6 (thanks to Anthony R!).
  4. Fixed order of vars_files includes in example in chapter 5 (thanks to @arbabnazar!).
  5. Fixed Solr log4j configuration file version check in chapter 4 (thanks to Leroy H!).
  6. Updated usage of `become` instead of now-deprecated `sudo` throughout book and examples (thanks to David!).
  7. Fixed task name text in idempotence example in chapter 4 (thanks to Joel S!).
  8. Fixed Node.js Forever installation in chapter 4 and chapter 6 due to Ansible `npm` module bug; `state=latest` is now `state=present` (thanks to Stephen W!).
  9. Add `geerlingguy.php-mysql` role to LAMP server example in chapter 6 (thanks to Paul M!).
  10. Fixed typo in "Configure PHP with `lineinfile`" example in chapter 4 (thanks to Adrian!).
  11. Fixed script name `digital_ocean.py` in bullet point 5 under the DigitalOcean dynamic inventory section in chapter 7 (thanks to Adrian!).

## Version 1.0 (2015-10-10)

  - Ansible 2.0! Ansible 2-specific sections and fixing things that are deprecated:
    - Added Blocks examples in chapter 5.
    - Added Dynamic includes section in chapter 6.
    - Replaced uses of `requirements.txt` with `requirements.yml` since the former is now deprecated.
  - Added example of zero-downtime deployments with HAProxy to chapter 9.
  - Completed remaining sections in chapter 9.
  - Changed EPEL installation process for RHEL/CentOS 7 in chapters 1 and 4 (thanks to @opratr!).
  - Completely rewrote GlusterFS section in chapter 8 with a more relevant example.
  - Rearranged first playbook example in chapter 2 so use of sudo is more obvious (thanks to @gkedge!).
  - Fixed typos in chapters 3 and 4 (thanks to @b_borysenko!).
  - Incorporated editorial changes in chapters 9, 10, and 11.
  - Incorporated editorial changes in appendices a and b.
  - Removed link to Ansible Guru, as it is no longer active (thanks to @mrjester888!).
  - Added link to SSH passwordless login/key-based authentication in chapter 1.
  - Added section on Ansible Vault in chapter 5.
  - Incorporated editorial changes in chapters 7 and 8.
  - Fixed various formatting issues in chapter 4 (thanks to @erimar77!).
  - Fixed incorrect reference to VirtualBox in chapter 2 (thanks to @chesterbr!).
  - Various small styling fixes in chapter 5 (thanks to Barry M!).
  - More helpful exposition of Git-related ad-hoc commands in chapter 3 (thanks to Stephen H!).
  - Replaced uses of 'installed' for state with 'present' (thanks to @b_borysenko!).
  - Fixed example of async_status usage in chapter 3 (thanks to @b_borysenko!).
  - Fixed line numbering and Composer installation in Drupal example in chapter 4.
  - Updated Ruby on Rails deployment example in chapter 9.
  - Updated LAMP Infrastructure example in chapter 8.
  - Updated Solr example in chapter 4.
  - Fixed Docker Flask app example in chapter 8.
  - Added foreword by Tim Gerla, Ansible, Inc. Co-Founder & CTO.
  - Added note about installing `sshpass` package (thanks to Larry B!).
  - Corrected playbook command under the "separate inventory files" section in chapter 7 (thanks to @lekum!).
  - Corrected an incorrect use of `--syntax-check` in chapter 11 (thanks to @lekum!).
  - Various tiny pre-launch tweaks and fixes.
  - Fixed incorrect reference to NFS in NTP example setup in chapter 2 (thanks to @atweb!).
  - Replaced mention of `service` command with `systemctl` for CentOS 7 in chapter 2 (thanks to @briants5!).
  - Fixed a number of formatting issues in code and paragraphs for print rendering.

## Version 0.99 (2015-07-19)

  - Incorporated editor's changes into chapters 5 and 6.
  - Added `--check` and `--syntax-check` information to chapter 11.
  - Added information about rolespec in chapter 11.
  - Fixed missing files in book's GitHub repository Node.js role example (thanks to @geoand!).
  - Fixed simple Node.js app server example playbook in chapter 4 (thanks to @erimar77!).
  - Fixed `lineinfile` task regex syntax in chapter 4 (thanks to @erimar77!).
  - Clarified EPEL requirements/installation for Enterprise Linux systems in chapter 1 (thanks to @michel_slm!).
  - Fixed a broken configuration item in chapter 4 playbook example.

## Version 0.97 (2015-06-10)

  - Incorporated editor's changes into chapter 4.
  - Added dynamic inventory examples in chapter 7.
  - Corrected a few other grammatical flaws in all chapters prior to chapter 4.
  - Added notes about getting a Python environment configured for barebones containers/CoreOS in chapter 8 (thanks to @andypost!).
  - Mentioned a way to bootstrap Ansible on Windows with Babun in appendix a (thanks to @jonathanhle!).
  - Added section on custom dynamic inventory in chapter 7, as well as code examples in the book's GitHub repository.

## Version 0.95 (2015-05-26)

  - Added Jenkins CI installation and usage guide in chapter 11.
  - Added section on `debug`, `fail` and `assert` in chapter 11.
  - Updated a few best practices and otherwise completed appendix b.
  - Removed appendix c (on Jinja2 and Ansible); will consider adding back in post-launch.

## Version 0.94 (2015-05-16)

  - Added information about Capistrano and blue-green deployments in chapter 9.
  - Reorganized chapter 9 with an eye towards a 1.0 release.
  - Merged chapter 12 into chapter 11 with an eye towards a 1.0 release.
  - Fixed `vagrant init` command in chapter 2 (thanks to Ned Schumann!).
  - Completed 'Delegation, Local Actions, and Pauses' section in chapter 5.
  - Completed DigitalOcean dynamic inventory example in chapter 7.
  - Fixed CentOS 6 vs 7 nomenclature in chapters 2 and 3 (thanks to @39digits and @aazon!).
  - Completed Ansible Tower installation guide in chapter 11.
  - Completed Ansible Tower usage guide and alternatives in chapter 11.

## Version 0.92 (2015-04-09)

  - Update Ansible project 'stars' count on GitHub in the introduction.
  - Added zero-downtime multi-server deployment example to chapter 9.
  - Removed frequent use of the filler word 'simply' (thanks to a reader's suggestion!).
  - Fixed language around 'plays' vs. 'tasks' in chapters 4, 5, and 6 (thanks to André!).
  - Fixed ad-hoc Django installation in chapter 3 (thanks to @wimvandijck!).

## Version 0.90 (2015-03-16)

  - Tweaked requirements.txt explanation in chapter 8.
  - Tweaked formatting of GlusterFS cookbook in chapter 6.
  - Fixed GlusterFS example ports and mount task in chapter 8.
  - Fixed some examples in chapter 4 to ensure apt repositories update cache.
  - Fixed some typos in chapter 8 (thanks to @queue_tip_!).
  - Updated Ansible installation instructions for Debian/Ubuntu in chapter 1.
  - Corrected use of yum module in fail2ban example in chapter 10 (thanks to @lekum!).
  - Fixed references to `ansible.cfg` config file in appendix b (thanks to @lekum!).
  - Fixed DigitalOcean provisioning playbook in chapter 8 (thanks to @jonathanhle!).
  - Adjusted DigitalOcean dynamic inventory example in chapter 7.
  - Rewrote completely nonsensical sentence in chapter 7 (thanks to @dan_bohea!).
  - Fixed some errors throughout the first few chapters (thanks to nesfel!).
  - Fixed a couple errors in chapters 2 and 4 (thanks to Barry McClendon!).

## Version 0.89 (2015-02-26)

  - Completed first deployment example for Rails app in chapter 9.
  - Added notes on role requirements.txt and requirements.yml options in chapter 6.
  - Tweaked language and cleaned up examples for roles in chapter 6.
  - Added GlusterFS cookbook to chapter 6.

## Version 0.88 (2015-02-13)

  - Fixed two errors in chapter 7 (thanks to Jonathan Le / @jonathanhle!)
  - Wrote introduction to chapter 9.
  - Wrote first deployment example for Rails app in chapter 9.

## Version 0.87 (2015-02-01)

  - Cleaned up Docker examples in chapter 8.
  - Fixed a typo in chapter 3 (thanks to Jonathan Le / @jonathanhle!)
  - Added section on configuring firewalls with `ufw` and `firewalld` in chapter 10.
  - Updated Apache Solr version in chapter 4 example.
  - Fixed APC uploadprogress task in Drupal example in chapter 4.
  - Added section on installing and configuring Fail2Ban in chapter 10.
  - Added suggestion for setting ANSIBLE_HOSTS environment variable in chapter 3 (thanks to Jason Baker / @diermakeralch!).
  - Added section on SELinux and AppArmor in chapter 10.
  - Completed chapter 10.

## Version 0.84 (2015-01-27)

  - Added Docker introduction and cookbooks in chapter 8.

## Version 0.81 (2015-01-11)

  - Fixed Vagrantfile examples to work with Vagrant 1.7.x.
  - Added local Mac configuration example in chapter 8.
  - Used `name` instead of `pkg` for packaging modules as per updated Ansible style guide.
  - Incorporated editorial changes for introduction, chapter 1, chapter 2, and chapter 3.
  - Fixed references to Vagrant Cloud/HashiCorp's Atlas.
  - Finished almost all the rest of chapter 5.

## Version 0.75 (2014-12-23)

  - Fixed code formatting in examples in chapter 8.
  - Added YAML `|` multiline variable delimiter example to appendix b.
  - Edited and updated examples and guide for HA Infrastructure in chapter 8.
  - Completed the ELK and Logstash Forwarder examples in chapter 8.
  - Started on the Mac provisioning example in chapter 8.

## Version 0.73 (2014-12-09)

  - Added `wait_for` to DigitalOcean example in chapter 7.
  - Completed Hightly-Available Infrastructure cookbook in chapter 8.
  - Began work on ELK log monitoring cookbook in chapter 8.
  - Fixed a few typos in chapters 5 and 6 (thanks to George Boobyer / @ibluebag!).
  - Incorporated edits in preface from technical editor.

## Version 0.71 (2014-11-27)

  - Added Highly-Available Infrastructure cookbook to chapter 8.
  - Updated screenshots throughout the book.
  - Began incorporating changes from copy editor (more to come!).

## Version 0.70 (2014-11-16)

  - Coverted Testing/CI section into its own chapter.
  - Added cowsay to chapter 12.
  - Removed glossary (and pointed readers directly to Ansible's very helpful glossary).
  - Added missing link in chapter 7.
  - Converted chapter 8 from "Ansible Modules" to "Ansible Cookbooks" due to reader interest.
  - Cleaned up Vagrantfile in chapter 3, as well as throughout `ansible-for-devops` git repo.
  - Added "Web Architecture Example" example to `ansible-for-devops` git repo.
  - Built structure of chapter 8 ("Ansible Cookbooks").
  - Added cowsay to chapter 8.
  - Added information about `add_host` and `group_by` to chapter 7.
  - Reworked sections in chapter 12 and fixed a few problems.

## Version 0.64 (2014-10-24)

  - Added Server Check.in architecture diagram (chapter 7).
  - Wrote about `host_vars`, `group_vars`, and dynamic inventory (chapter 7).
  - Added Digital Ocean provisioning and dynamic inventory walkthrough (chapter 7).

## Version 0.62 (2014-10-07)

  - Wrote a good deal of chapter 7 (Inventories).
  - Cleaned up code examples to follow updated best practices in appendix b.
  - Updated installation instructions to use Ansible's official PPA for Ubuntu (thanks to Rohit Bhute!).

## Version 0.60 (2014-09-30)

  - Wrote most of appendix b (Best Practices).
  - Updated definition of idempotence in chapter 1.
  - Fixed a few LeanPub-related code formatting issues.
  - Many grammar fixes throughout the book (thanks to Jon Forrest!).
  - Some spelling and ad-hoc command fixes (thanks to Hugo Posca!).
  - Had a baby (thus the dearth of updates from 8/1-10/1 :-).
  - Wrote introduction and basic structure of chapter 11 (Ansible Tower).

## Version 0.58 (2014-08-01)

  - Even more sections on variables in chapter 5 (almost finished!).
  - Fixed a few old Ansible and Drupal version references.
  - Added a playbook include tag example in chapter 6.
  - Completed first draft of chapter 6.
  - Fixed broken handler in chapter 4's Tomcat handler (thanks to Joel Shprentz!).
  - Fixed a missing closing quotation in chapter 3 example (thanks to Jonathan Nakatsui!).

## Version 0.56 (2014-07-20)

  - Filled in many more sections on variables in chapter 5.
  - Some editing in chapter 6.
  - Side work on some supplemental material for a potential chapter on Docker.

## Version 0.54 (2014-07-02)

  - Finished roles section in chapter 6.
  - Fixed a few code examples for better style in chapter 4.
  - Fixed references to official code repository in chapters 4 and 6.

## Version 0.53 (2014-06-28)

  - Added note about [Windows Support](http://docs.ansible.com/intro_windows.html) in appendix a.
  - Wrote large portion of roles section in chapter 6.

## Version 0.52 (2014-06-14)

  - Adjusted some code listings to make more readable line breaks.
  - Added section on Ansible testing with Travis CI in chapter 12.
  - Expanded mention of Ansible's excellent documentation in introduction.
  - Greatly expanded security coverage in chapter 10.
  - Added link to security role on Ansible Galaxy in chapter 10.

## Version 0.50 (2014-05-05)

  - Wrote includes section in chapter 6.
  - Added links to code repository examples in chapters 4 and 6.
  - Fixed broken internal links.
  - Fixed typos in chapter 10.
  - Added note about `--force-handlers` (new in Ansible 1.6) in chapter 4.
  - Use Ansible's `apache2_module` module for LAMP example in chapter 4.
  - Moved Jinja2 chapter to appendix c.
  - Removed 'Variables' chapter (variables will be covered in-depth elsewhere).
  - Added Appendix B - Ansible Best Practices and Conventions.
  - Started tagging code in [Ansible for DevOps GitHub repository](https://github.com/geerlingguy/ansible-for-devops) to match manuscript version (starting with this version, 0.50).
  - Fixed various layout issues.

## Version 0.49 (2014-04-24)

  - Completed history of SSH in chapter 10.
  - Clarified definition of the word 'DevOps' in chapter 1.
  - Added section "Testing Ansible Playbooks" in chapter 14.
  - Added links to [Ansible for DevOps GitHub repository](https://github.com/geerlingguy/ansible-for-devops) in the introduction and chapter 4.

## Version 0.47 (2014-04-13)

  - Added Apache Solr example in chapter 4.
  - Updated VM diagrams in chapter 4.
  - Added information about `ansible-playbook` command in chapter 4 (thanks to a reader's suggestion!).
  - Clarified code example in preface.

## Version 0.44 (2014-04-04)

  - Expanded chapter 10 (security).
  - Fixed formatting issues in Warning/Info/Tip asides.
  - Fixed formatting of some code examples to prevent line wrapping.
  - Added section on Ansible Galaxy in chapter 6.
  - Updated installation section in chapter 1 with simplified install processes.
  - Added warnings concerning faster SSH in Ansible 1.5+ (thanks to @LeeVanSteerthem!).

## Version 0.42 (2014-03-25)

  - Added history of SSH section.
  - Expanded chapter 10 (security).
  - Many small spelling and grammar mistakes corrected.
  - Fixed formatting of info/warning/tip asides.

## Version 0.38 (2014-03-11)

  - Added Appendix A - Using Ansible on Windows workstations (thanks to a reader's suggestion!).
  - Updated chapter 1 to include a reference to appendix a.
  - Clarified and expanded installation instructions for Mac and Linux in chapter 1.
  - Added chapter 10 - Server Security and Ansible
  - Updated chapter 1 to include a reference to chapter 10.
  - Added notes to a few more areas of the book (random).

## Version 0.35 (2014-02-25)

  - Added this changelog.
  - Split out roles and playbook organization into its own chapter.
  - Expanded 'Environment Variables' section in chapter 5.
  - Expanded 'Variables' section in chapter 5.
  - MORE COWBELL! (Cowsay motivational quotes at the end of every completed chapter).
  - Fixed NTP installation examples in chapter 2 (thanks to a reader's suggestion!).

## Version 0.33 (2014-02-20)

  - Initial published release, up to chapter 4, part of chapter 5.
