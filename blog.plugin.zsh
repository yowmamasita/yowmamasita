#!/usr/bin/env zsh

# Let's use GitHub gists and profile readme as your blog!
# Why?
# - You can use markdown
# - It's Google-indexed
# - There's a built-in comment system (GitHub might have the coolest signup UX)
# - Performance is good to great
#
# Your homepage https://github.com/$USERNAME
# Your blog index https://gist.github.com/$USERNAME
#
# Install (oh-my-zsh)
# wget https://raw.githubusercontent.com/yowmamasita/yowmamasita/main/blog.plugin.zsh ~/.oh-my-zsh/custom/plugins/blog
# Or just copy and paste this to your .zshrc

function blog() {
	profile_readme_path="$HOME/README/README.md"
	profile_readme_dir=$(dirname $profile_readme_path)
	filename="$(echo $1 | awk '{gsub("[^a-zA-Z0-9 ]", ""); gsub(" ", "-"); print tolower($0)}').md"
	echo "# $1\n\n" > $filename
	$EDITOR $filename
	url=$(gh gist create -p $filename -d $1)
	latest="I recently wrote about"
	entry="$latest [$1]($url)"
	entry_esc=$(printf '%s\n' "$entry" | sed -e 's/[]\/$*.^[]/\\&/g');
	username=$(gh api graphql -f query='query{viewer{login}}' -q '.data.viewer.login')
	if [ ! -d "$profile_readme_dir" ] && [ ! -z "$username" ]; then
		gh repo clone "$username/$username" $profile_readme_dir
	fi
	(cd $profile_readme_dir && git fetch origin && git checkout origin/HEAD)
	if grep -Fq $latest $profile_readme_path; then
		sed -i.bak "s/$latest.*/$entry_esc/g" $profile_readme_path
	else
		echo $entry >> $profile_readme_path
	fi
	if [ $(pwd) != $profile_readme_dir ]; then
		mv -f $filename $profile_readme_dir
	fi
	(cd $profile_readme_dir && git add . && git commit -am "new blog post: $1" && git push origin HEAD:main)
	echo "Done, blog post: $url"
	echo "Your profile: https://github.com/$username"
}
