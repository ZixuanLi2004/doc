mkdocs build
mkdocs gh-deploy --remote-name origin --remote-branch gh-pages
git add .
git commit -m "update"
git push