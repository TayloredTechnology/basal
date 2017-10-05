# $1 is the branch that we are merging master into
#if [ "$#" -ne 1 ]; then
#  echo "Branch to merge master into must be specified" 
#  exit 1
#fi

for branched in $(git for-each-ref refs/heads | cut -d/ -f3-); do
  [ "$branched" == "master" ] && continue
  git checkout $branched
  git checkout master -- ./$branched
  git commit -am "Release Master Changes"
done

git checkout master
