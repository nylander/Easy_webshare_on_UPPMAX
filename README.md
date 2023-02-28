# Easy Web Share on UPPMAX

File: `webshare.sh`

By: Johan.Nylander\@nbis.se

See also: [https://uppmax.uu.se/support-sv/user-guides/webexport-guide](https://uppmax.uu.se/support-sv/user-guides/webexport-guide)

---

#### For the Impatient:

    mkdir -p /proj/xyz123/webexport/share
    cd /proj/xyz123/webexport/share
    cp -r /path/to/some_folder_or_file .
    /proj/snic2022-22-328/dlbin/webshare.sh

---

## HOWTO

In this example we wish to share sequences delivered to your project's
INBOX (folder `/proj/xyx123/INBOX/My.Name_15_00`) so it can be accessible
on the URL [https://export.uppmax.uu.se/xyz123/seqs/](https://export.uppmax.uu.se/zyz123/seqs/).
Note that you need to change `xyz123` and `My.Name_15_00` to fit your needs.

### 1. Localize the `webshare.sh` script

You may either download the script from the GitHub repository
[https://github.com/nylander/Easy_webshare_on_UPPMAX](https://github.com/nylander/Easy_webshare_on_UPPMAX),
or use a copy already available on Uppmax.

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
transferred from the `INBOX` -- you need to use the `cp` command in order to
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

## Important note on file areas and project IDs

New naming conventions of project folders on UPPMAX have comlicated matters
when sharing slightly.  A project folder, or "folder area", can now be named
something simple as `/proj/bobsproject`. And you may put a `webexport` folder
inside `/proj/bobsproject` with files to be shared. However, the `bobsproject`
folder will belong to a SNIC/NAISS project, e.g., `snic2022-12-345`, and it is
this ID that is going to be needed in the URL for the web export server, e.g.,
https://export.uppmax.uu.se/snic2022-12-345/ (and not
https://export.uppmax.uu.se/bobsproject/).

The conversion between the folder name and the SNIC/NAISS project ID is now
handled automatically by the script.

To see which project your project area belongs to, use the `uquota` script on
rackham.

---

## The `webshare.sh` script:

#### Usage

    webshare.sh [-h] [-f folder] [-u user] [-p projid]

#### Description

    Webshare files in /proj/<id>/webexport/<folder>/.
    The URL (password protected) will be https://export.uppmax.uu.se/<projid>/<folder>/
    Note that the URL needs to contain a Project ID, which may or may not be the same
    as the <id> (the File area). If uncertain, check with the command 'uquota' on rackham.
    Usage:
        First, create <folder> with content to be shared.
        Then, cd to <folder> and run:

            webshare.sh

        The user and password will be written to stdout. Write them down.
        Optionally, both <folder> (full path!), <user> and <projid> can be given as arguments:

            webshare.sh -f <folder> -u <user> -p <projid>

        The <folder> will be created if not already present.
        Also note that the folder must reside inside a project 'webexport' folder.

## Download

[https://github.com/nylander/Easy_webshare_on_UPPMAX](https://github.com/nylander/Easy_webshare_on_UPPMAX)


## License and copyright

Copyright (c) 2016-2023 Johan Nylander

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

