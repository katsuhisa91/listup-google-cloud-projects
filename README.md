# listup-google-cloud-projects

再帰的に組織内のGoogle Cloudプロジェクトをリストアップするスクリプト。

Google Cloud の Cloud Shell を起動し、以下を実行することで実行可能です。

```sh
$ git clone https://github.com/katsuhisa91/listup-google-cloud-projects.git
$ cd listup-google-cloud-projects
$ chmod 755 listup.sh
$ ./listup.sh
```

なお、環境によってはプロジェクトIDが`sys-`ではじまるApps Script プロジェクトが大量表示されるかもしれませんが、以下のように実行することで除外して表示することができます。（[参考記事](https://developers.google.com/apps-script/guides/cloud-platform-projects)）

```sh
$ ./listup.sh | grep -v sys
```