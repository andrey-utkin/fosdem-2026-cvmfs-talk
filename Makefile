default:
	# No default command, think your commands through!
	false

deploy-prod:
	git push
	pushd ${HOME}/work/projects/website/website-personal/static/talks/cvmfs-fosdem26-talk/slides && git pull && pushd ../../../../ && make deploy-prod
