---
layout: "documents"
page_title: "Contiv Community"
sidebar_current: "community"
description: |-
  Contributing to Contiv
---
# Contributing to Contiv

Submitting code changes is only one of the many ways to contribute.
Reporting issues, proposing documentation and design changes,
discussing use cases and proposing integration with other software
from the ecosystem are more ways to contribute to Contiv.
Contributors can also become maintainers or committers.

All contributions are welcome, no matter how small or how big they are.

Various repos may have more specific requirements for contribution - check out CONTRIBUTING.md
files in respective repos.

## Reporting Issues
You can report an issue in a specific repo by 
clicking `New Issue` in the respective repo.
Issues should also be opened for feature requests.

## Submitting pull requests for code or documentation changes
Changes can be proposed by sending a pull request (PR). One of the committers
will review the changes and provide feedback. The pull request will be merged
into the master branch after discussion.

Please make sure that all tests are passing before
submitting the PR, as applicable.
Please keep in mind some changes might not be merged if committers
decide they can't be merged.


## Submitting proposals for major changes
Please include `Proposal: ...` in the title of the issue if you wish to
do significant refactoring of the code, to propose a new component or to
introduce a major change. Marking the issue as a proposal will ensure that
more people provide feedback as early as possible.

Significant code changes submitted without an accompanying proposal might
be rejected and not merged. Such significant submissions without a proposal are
discouraged to avoid wasting time.


After design discussions:
- Fork the repository to your own public repository
- Make the changes in your repository in a new branch
- Add unit and system test cases for your code, as appropriate
- Make sure existing tests and newly added tests pass, as appropriate
- Rebase your branch on top of the latest master branch
- Re-run the unit and system tests
- Submit a pull request with the code changes
- A discussion may take place on your pull request
- Discussion while writing the code is also recommended
- Requested changes should be made to the same branch on your fork
- Changes should be force pushed to the same branch of the pull request
- The unit and system tests may need to be run again after committers `LGTM` the change
- One of the committers will merge the changes


## Discussing use cases and requesting new features
Submit an issue to discuss your use case. A description of the use case
should be provided. The description should also explain why the existing
features don't help with this use case.
Feature requests should have a title which starts with `Feature request: ...`.
We encourage the inclusion of diagrams (or pictures of drawings) and other
details to provide a better description of the use case.


## Becoming a committer
Play with the code and know it inside out. Once you think you are comfortable
with the code and you think you are ready to become a committer, you can send
an email to one of the committers. For more information, see [GOVERNANCE.md](GOVERNANCE.html)

## Commit message format guidelines
The commit message should have a short summary of no more than 50
characters on the first line. The description should use verbs in the imperative
(e.g. `netmaster: fix bug`, not `netmaster: fixed bug`).
The second line should be left empty.

A longer description of what the commit does should start on the third line when
such a description is deemed necessary. This description needs to be wrapped to
72 characters. Paragraphs following this one should have an empty line above
them.


## Legal Stuff: Sign your work
You must sign off on your work by adding your signature at the end of the
commit message. Your signature certifies that you wrote the patch or
otherwise have the right to pass it on as an open-source patch. 
By signing off your work you ascertain following (from [developercertificate.org](http://developercertificate.org/)):

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
660 York Street, Suite 102,
San Francisco, CA 94110 USA

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

Every git commit message must have the following at the end on a separate line:

    Signed-off-by: Joe Smith <joe.smith@email.com>

Your real legal name has to be used. Anonymous contributions or contributions
submitted using pseudonyms cannot be accepted.

Two examples of commit messages with the sign-off message can be found below:
```
netmaster: fix bug

This fixes a random bug encountered in netmaster.

Signed-off-by: Joe Smith <joe.smith@email.com>
```
```
netmaster: fix bug

Signed-off-by: Joe Smith <joe.smith@email.com>
```

If you set your `user.name` and `user.email` git configuration options, you can
sign your commits automatically with `git commit -s`.

These git options can be set using the following commands:
```
git config user.name "Joe Smith"
git config user.email joe.smith@email.com
```

`git commit -s` should be used now to sign the commits automatically, instead of
`git commit`.
