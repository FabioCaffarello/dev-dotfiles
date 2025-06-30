function cleanup() {
  containers=$(docker ps -a -q)
  if [ -n "$containers" ]; then 
    for container in ${(f)containers}; do
      docker rm -f $container;
    done
    echo "All constainers removed"
  else
    echo "No containers to remove"
  fi
} 
