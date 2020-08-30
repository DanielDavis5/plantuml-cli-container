# MIT License
#
# Copyright (c) 2020 Daniel Maurice Davis
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -eu

: ${PLANTUML_DOWNLOAD_URL:='https://sourceforge.net/projects/plantuml/files/1.2020.16/plantuml.1.2020.16.jar/download'}

# create the working container
working_container=$(buildah from alpine:3.12.0)

# when the script exits, remove the working container
trap 'buildah rm "$working_container" &>/dev/null' EXIT HUP INT TERM

# install some nice packages
buildah run $working_container apk add --no-cache \
    openjdk8 \
    graphviz \
    curl \
    ttf-dejavu

# download the plantuml jar
buildah run $working_container curl -L "$PLANTUML_DOWNLOAD_URL" \
    -o /usr/local/lib/plantuml.jar

# set plantuml as the entrypoint
buildah config --entrypoint \
    '["java", "-jar", "/usr/local/lib/plantuml.jar"]' \
    $working_container

# if the user doesn't supply args just print the help
buildah config --cmd "-h" $working_container

# commit the container to the local repo
buildah commit $working_container plantuml-cli
