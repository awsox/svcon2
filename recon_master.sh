#!/bin/bash

# Main recon automation script
input_file="domains.txt"
output_dir="project"
wordlist="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"

# Create output directories
mkdir -p $output_dir/recon/{passive,active,resolved}
mkdir -p $output_dir/tech-detect/{wordpress,custom}

# Read each domain from the input file
while read domain; do
  echo "[*] Processing domain: $domain"

  # Create domain-specific directory
  domdir="$output_dir/recon/$domain"
  mkdir -p $domdir

  # Passive subdomain enumeration
  subfinder -d $domain -silent -all > $domdir/subs_subfinder.txt
  assetfinder --subs-only $domain > $domdir/subs_assetfinder.txt

  # Active brute-force subdomain discovery
  shuffledns -d $domain -w $wordlist -rL /etc/resolv.conf > $domdir/subs_shuffledns.txt

  # Combine and deduplicate results
  cat $domdir/subs_*.txt | sort -u > $domdir/all_subs.txt

  # Probe for alive hosts with HTTP/HTTPS
  httpx -l $domdir/all_subs.txt -silent -title -tech-detect -status-code -json > $domdir/live.json
  cat $domdir/live.json | jq -r 'select(.webserver != null) | .url' > $domdir/live.txt

  # Store live subdomains globally
  cp $domdir/live.txt $output_dir/recon/resolved/$domain.txt

  # CMS classification
  echo "[*] Detecting CMS..."
  jq -r 'select(.technologies[]?.name | ascii_downcase | test("wordpress")) | .url' $domdir/live.json > $output_dir/tech-detect/wordpress/$domain.txt
  jq -r 'select(.technologies | length == 0 or (.[]?.name | ascii_downcase | test("wordpress") | not)) | .url' $domdir/live.json > $output_dir/tech-detect/custom/$domain.txt

done < "$input_file"

echo "[+] Recon completed! Results are stored in: $output_dir"
