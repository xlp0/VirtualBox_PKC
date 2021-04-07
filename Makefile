# More detailed instructions can be found: https://devconnected.com/how-to-delete-file-on-git/
init:
	./powerup.sh

shutdown:
	vagrant halt

removeMediaFiles: 
	git filter-branch -f --prune-empty --index-filter "git rm -r --cached --ignore-unmatch ./backup/MediaFiles/*" HEAD
	git push origin --mirror --force
	git gc --aggressive --prune=all     # remove the old files
	git push --set-upstream origin main

allow_unrelated:
	git pull origin main --allow-unrelated-histories

reset:
	rm -rf .git
	git init
	git add .
	git checkout -b main
	git commit -m 'Reset the history at ${CURRENT_TIME} for storge preservation'
	git remote add origin git@github.com:xlp0/VirtualBox_PKC.git
	git push origin --mirror --force
	git gc --aggressive --prune=all     # remove the old files
	git push --set-upstream origin main