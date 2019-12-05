# Easy Web Share on UPPMAX

File: `webshare.sh`

By: Johan.Nylander\@nbis.se

See also: [https://uppmax.uu.se/support-sv/user-guides/webexport-guide](https://uppmax.uu.se/support-sv/user-guides/webexport-guide)

---

#### For the Impatient:

    mkdir -p /proj/xyz123/webexport/share
    cd /proj/xyz123/webexport/share
    cp -r /path/to/some_folder_or_file .
    /proj/snic2017-7-343/dlbin/webshare.sh

---

## HOWTO 

In this example we wish to share sequences delivered to your project's
INBOX (folder `/proj/xyz123/INBOX/My.Name_15_00`) so it can be accessible
on the URL [https://export.uppmax.uu.se/b123456/seqs/](https://export.uppmax.uu.se/xyz123/seqs/).
Note that you need to change `xyz123` and `My.Name_15_00` to fit your needs.


### 1. Localize the `webshare.sh` script

You may either download the script from the GitHub repository
[https://github.com/nylander/Easy_webshare_on_UPPMAX](https://github.com/nylander/Easy_webshare_on_UPPMAX),
or use a copy already available on Uppmax (full path:
`/proj/snic2017-7-343/dlbin/webshare.sh`).

Convenient would be to put the script in your `PATH`. For example:

    export PATH=$PATH:/proj/snic2017-7-343/dlbin


### 2. Create a folder to share

Files to be shared from UPPMAX need to be in a special place in order for the
web server to see them. This means that we need to put files from our INBOX to
a folder inside a `webexport` folder. In this example, we wish the shared
folder to be named `seqs`, and this folder need to be inside the
`/proj/xyz123/webexport` folder.  If you don't already have the `webexport`
folder, you may create it first, or simply do:

    mkdir -p /proj/xyz123/webexport/seqs


### 3. Copy files to be shared to the newly created folder 

**Note**: this applies specifically for files and folders that will be
transferred from the `INBOX` - you need to use the `cp` command in order to
correctly change the ownerships of the transferred files! Normally you would
have used, e.g., `mv`, but this will not work on UPPMAX (UPPMAX's `mv` changes
ownerships correctly for files, but not for folders). Furthermore, the files
need to be readable by the web server, so symbolic links will not work.

So to copy a whole folder, use:

    cp -r /proj/xyz123/INBOX/My.Name_15_00 /proj/xyz123/webexport/seqs


### 4. Run the `webshare.sh` script to create a password protected URL

Easiest is to `cd` into the folder to be shared:

    cd /proj/xyz123/webexport/seqs

and then run the script without arguments:

    webshare.sh

(or, if the script is not found in the PATH, try
`/proj/snic2017-7-343/dlbin/webshare.sh`)


### 5. Share the link!

The output from the script looks something like this:

    Folder to share (set by pwd): /proj/xyz123/webexport/seqs/

          URL: https://export.uppmax.uu.se/xyz123/seqs/
    User Name: kxlvtr
     Password: cvtddq

    Need a tip? Try

      wget -m -nH -np --cut-dirs=1 -R "index.html*" --user=kxlvtr --password=cvtddq  https://export.uppmax.uu.se/xyz123/seqs/
    
Make sure you write down the information and then share it.

When someone attempts to access the URL (note the trailing slash)
[https://export.uppmax.uu.se/xyz123/seqs/](https://export.uppmax.uu.se/xyz123/seqs/),
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
