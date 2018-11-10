### happychild-aws-settings

### Usage
- IAM
```
envchain happychild miam -a --dry-run -f IAMfile  # dry-run
envchain happychild miam -a -f IAMfile  # apply
```

- Security Group
```
envchain happychild piculet -a --dry-run -f Groupfile  # dry-run
envchain happychild piculet -a -f Groupfile # apply
```

- Route 53
```
envchain happychild roadwork -a --dry-run -f Routefile # dry-run
envchain happychild roadwork -a -f Routefile # dry-run
```

- Deploy
Must put 'secrets.env' on '/hako/secrets.env' before deploy. 'secrets.env' include some secret key like db passwords.
```
envchain happychild  hako deploy hako/happychild-staging.jsonnet -t develop # development
envchain happychild  hako deploy hako/happychild-staging.jsonnet -t master  # production
```
