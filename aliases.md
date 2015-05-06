
[alias]
  hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
  ll   = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
  logg  = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
  co = checkout

```
$ git config --gloabl alias.co checkout
$ git config --global alias.unstage 'reset HEAD --'
...
```
