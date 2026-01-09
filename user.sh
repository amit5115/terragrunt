#!/bin/bash

# =========================
# SAFETY CHECK
# =========================
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

echo "===== USER & GROUP MANAGEMENT POC ====="

# =========================
# INPUT
# =========================
read -p "Enter username to create: " USERNAME
read -p "Enter group name to create: " GROUPNAME
read -p "Enter directory to assign (e.g. /data/$USERNAME): " DIR
read -p "Enter permission (e.g. 750): " PERM

# =========================
# CREATE GROUP
# =========================
if getent group "$GROUPNAME" >/dev/null; then
  echo "ℹ️ Group '$GROUPNAME' already exists"
else
  groupadd "$GROUPNAME"
  echo "✅ Group '$GROUPNAME' created"
fi

# =========================
# CREATE USER
# =========================
if id "$USERNAME" >/dev/null 2>&1; then
  echo "ℹ️ User '$USERNAME' already exists"
else
  useradd -m -g "$GROUPNAME" "$USERNAME"
  echo "✅ User '$USERNAME' created"
fi

# =========================
# ADD USER TO GROUP
# =========================
usermod -aG "$GROUPNAME" "$USERNAME"
echo "✅ User '$USERNAME' added to group '$GROUPNAME'"

# =========================
# DIRECTORY SETUP
# =========================
mkdir -p "$DIR"
chown "$USERNAME:$GROUPNAME" "$DIR"
chmod "$PERM" "$DIR"

echo "✅ Directory '$DIR' created"
echo "✅ Ownership set to $USERNAME:$GROUPNAME"
echo "✅ Permission set to $PERM"

# =========================
# VALIDATION
# =========================
echo
echo "===== VALIDATION ====="
id "$USERNAME"
ls -ld "$DIR"

echo
echo "🎉 POC COMPLETED SUCCESSFULLY"
