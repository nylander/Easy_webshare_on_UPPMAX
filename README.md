# Easy Web Share on UPPMAX

File: `/proj/uppstore2017206/b2011210/dlbin/webshare.sh`

By: Johan.Nylander\@nbis.se

Version: Tue 29 Jan 2019 04:55:27 PM CET

See also: [http://uppmax.uu.se/support-sv/user-guides/webexport-guide](http://uppmax.uu.se/support-sv/user-guides/webexport-guide)

---

#### For the Impatient:

    mkdir -p /proj/xyz123/webexport/share
    cd /proj/xyz123/webexport/share
    cp -r /path/to/some_folder_or_file .
    /proj/uppstore2017206/b2011210/dlbin/webshare.sh

---

## HOWTO 

In this example we wish to share sequences delivered to your project's
INBOX (folder `/proj/b123456/INBOX/My.Name_15_00`) so it can be accessible
on the URL [https://export.uppmax.uu.se/b123456/seqs/](https://export.uppmax.uu.se/b123456/seqs/).
Note that you need to change `b123456` and `My.Name_15_00` to fit your needs.

### 1. Set PATH in order to find the script

You can run the script by specifying the full path, or alternatively, make sure you have
the `/proj/uppstore2017206/b2011210/dlbin` directory in your PATH variable:

    export PATH=$PATH:/proj/uppstore2017206/b2011210/dlbin

(The above line can also be included in your `.bash_profile`).

The full path to the script is `/proj/uppstore2017206/b2011210/dlbin/webshare.sh`.


### 2. Create a folder to share

Files to be shared from UPPMAX need to be in a special place in order for
the web server to see them. This means that we need to put files from our INBOX to a
folder inside a `webexport` folder. In this example, we wish the shared folder to be
named `seqs`, and this folder need to be inside the `/proj/b123456/webexport` folder.
If you don't already have the `webexport` folder, you may create it first,
or simply do:

    mkdir -p /proj/b123456/webexport/seqs


### 3. Copy files to be shared to the newly created folder 

**Note**: this applies specifically for files and folders that will be transferred
from the `INBOX` - you need to use the `cp` command in order to correctly change the
ownerships of the transferred files! Normally you would have used, e.g., `mv`, but this
will not work on UPPMAX (UPPMAX's `mv` changes ownerships correctly for files, but not
for folders). Furthermore, the files need to be readable by the web server, so symbolic
links will not work.

So to copy a whole folder, use:

    cp -r /proj/b123456/INBOX/My.Name_15_00 /proj/b123456/webexport/seqs


### 4. Run the `webshare.sh` script to create a password protected URL

Easiest is to `cd` into the folder to be shared:

    cd /proj/b123456/webexport/seqs

and then run the script without arguments:

    webshare.sh

(or, if the script is not found in the PATH, try `/proj/uppstore2017206/b2011210/dlbin/webshare.sh`)

### 5. Share the link!

The output from the script looks something like this:

    Folder to share (set by pwd): /proj/b123456/webexport/seqs/

          URL: https://export.uppmax.uu.se/b123456/seqs/
    User Name: kxlvtr
     Password: cvtddq

    Need a tip? Try

      wget -r -nH -np --cut-dirs=1 -R "index.html*" --user=kxlvtr --password=cvtddq  https://export.uppmax.uu.se/b123456/seqs/
    
Make sure you write down the information and then share it.

When someone attempts to access the URL (note the trailing slash)
[https://export.uppmax.uu.se/b123456/seqs/](https://export.uppmax.uu.se/b123456/seqs/),
they will be prompted for a User Name (`kxlvtr`), and a Password (`cvtddq`).

---

## The `webshare.sh` script:

#### Usage

    webshare.sh [-h] [-f folder] [-u user]

#### Description

    Webshared files in /proj/<projid>/webshare/<folder>/.
    The URL (password protected) will be https://export.uppmax.uu.se/<projid>/<folder>/
    Usage:
        First, create <folder> with content to be shared.
        Then, cd to <folder> and run:

            webshare.sh

        The user and password will be written to stdout. Write them down.
        Optionally, both <folder> (full path!) and <user> can be given as arguments:

            webshare.sh -f <folder> -u <user>

        The <folder> will be created if not already present.
        Also note that the folder must reside inside a projects 'webshare' folder.


## Source

[https://github.com/nylander/Easy_webshare_on_UPPMAX](https://github.com/nylander/Easy_webshare_on_UPPMAX)
