# DB Stack Runbook

This runbook describes how to deploy, verify, backup, and restore the DB stack.

---

## 1. Deploy the stack

All services are deployed using Ansible:

```bash
ansible-playbook -i inventory.yml playbook.yml --ask-pass --ask-vault-pass --ask-become-pass
```

Notes:

- For VM used only password type SSH connection and required sudo password
- Vault password is required for database and PgBouncer credentials. (for this configuration it`s 12345)
- The stack includes:
  - PostgreSQL
  - PgBouncer
  - Backup container (`pg_backup`)

---

## 2. Verify the stack

Check running containers:

```bash
docker compose ps
```

Check PostgreSQL health:

```bash
docker compose exec -it postgres pg_isready -U postgres
```

Check PgBouncer health:

```bash
docker compose exec -it pgbouncer pg_isready -h 127.0.0.1 -p 6432
```

Verify backups:

```bash
ls /srv/backups/postgres
cat /srv/backups/postgres/backup.log
```

Logs include:

```
[INFO] Starting backup at <date>
[INFO] Backup created: backup_YYYY-MM-DD_HH-MM.sql.gz
[INFO] Deleted old backup: backup_YYYY-MM-DD_HH-MM.sql.gz
```

---

## 3. Restore from backup

Choose the backup file you want to restore:

```bash
gunzip -c /srv/backups/postgres/backup_YYYY-MM-DD_HH-MM.sql.gz | \
docker compose exec -T postgres psql -U postgres -d postgres
```

## 4. Restart the stack

```bash
docker compose up -d
```

---

## 5. Tail backup logs

```bash
tail -f /srv/backups/postgres/backup.log
```

This shows when backups are created and which old backups were deleted.


