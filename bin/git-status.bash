
alias __trim="tr '\0\n' '\n '"

__git_status ()
{
  local branch="$(git symbolic-ref HEAD 2>/dev/null | __trim | cut -c12-)"
  local changed="$(git diff --name-status 2>/dev/null | grep -v '^U' | wc -l | __trim)" 
  local staged="$(git diff --staged --name-status 2>/dev/null | grep -v '^U' | wc -l | __trim)" 
  local conflicts="$(git diff --staged --name-status 2>/dev/null  | grep '^U' | wc -l | __trim)" 
  local untracked="$(git status --porcelain 2>/dev/null | wc -l | __trim)" 
  local ahead=0
  local behind=0

  if [[ -z "$branch" ]]; then 
	  branch="$(git rev-parse --short HEAD 2>/dev/null | __trim)"
  else
	  local remote_name="$(git config branch.$branch.remote)"
	  if ! [[ -z "$remote_name" ]]; then
		  local merge_name="$(git config branch.$branch.merge)"
		  local remote_ref=$merge_name
		  if [[ "$remote_name" -ne "." ]]; then
			  local merge_name_fixed="$(echo $merge_name | cut -c12-)"
			  remote_ref="refs/remotes/$remote_name/$merge_name_fixed"
		  fi
		  local revgit="$(git rev-list --left-right $remote_ref...HEAD)"
		  if [[ -z "$revgit" ]]; then
			  revgit="$(git rev-list --left-right $merge_name...HEAD)"
		  fi
		  ahead="$(echo -e $revgit | grep '^>' | wc -l)"
		  behind="$(echo -e $revgit | grep -v '^>' | wc -l)"
	  fi
  fi
  echo "$branch $ahead $behind $staged $conflicts $changed $untracked"
}

__git_status_ps1 ()
{
  local g=()
  IFS=' ' read -r -a g <<< "$(__git_status)"  
  
  local bold="\e[1m"
  local reset_color="\e[0m"
  local branch="${g[0]}"
  local ahead="↑${g[1]}"
  local behind="↓${g[2]}" 
  local staged="\e[38;5;197m$boldΞ${g[3]}"
  local conflicts="\e[38;5;37m$bold!${g[4]}"
  local changed="\e[38;5;208m$bold±${g[5]}"
  local untracked="⁃${g[6]}" 

  # Show exit status
  local exit_status=""
  if [[ "$?" == "0" ]]; then
	  exit_status="\e[38;5;66m➜  "
  else
	  exit_status="\e[38;5;197m➜  "
  fi

  local git_changes=""
  if [[ "${g[1]}" != "0" ]]; then
	  git_changes="${git_changes}${ahead}${reset_color}"
  fi
  if [[ "${g[2]}" != "0" ]]; then
	  git_changes="${git_changes}${behind}${reset_color}"
  fi
  if [[ "${g[3]}" != "0" ]]; then
	  git_changes="${git_changes}${staged}${reset_color}"
  fi
  if [[ "${g[4]}" != "0" ]]; then
	  git_changes="${git_changes}${conflicts}${reset_color}"
  fi
  if [[ "${g[5]}" != "0" ]]; then
	  git_changes="${git_changes}${changed}${reset_color}"
  fi
  if [[ "${g[6]}" != "0" ]]; then
	  git_changes="${git_changes}${untracked}${reset_color}"
  fi

  local git_changes_color="\e[38;5;83m$bold"
  if ! [[ -z "$git_changes" ]]; then
	  git_changes_color="\e[38;5;196m$bold"
	  git_changes="($git_changes)"
  fi
  
  if [[ "$branch" == "0" ]]; then
  	PS1="${exit_status}${reset_color}$@ "
  else
  	PS1="${exit_status}${reset_color}$@ b:${git_changes_color}${branch}${reset_color} ${git_changes} "
  fi
}

