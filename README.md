# repair_wp_hack
Script to clean up after my Wordpress was hacked

## Installation 
* log in to your hacked server (via ssh)
* cd to a folder where you have 'write' permissions

	git clone https://github.com/pforret/repair_wp_hack.git
	cd repair_wp_hack


# Valuable articles
* https://wordpress.org/support/topic/resolved-cutwin-javascript-injection/
* https://wordpress.org/support/article/faq-my-site-was-hacked/
* https://smackdown.blogsblogsblogs.com/2008/06/24/how-to-completely-clean-your-hacked-wordpress-installation/

## Test your site

* https://sitecheck.sucuri.net/ (site keeps a cached version of your site, used a random parameter ?test=7763 afetr the URL to get a new scan)
* http://www.unmaskparasites.com/
* https://www.virustotal.com/gui/home/url

## Check if your site has been flagged as unsafe

* https://transparencyreport.google.com/safe-browsing/search
* https://global.sitesafety.trendmicro.com/
* https://www.trustedsource.org/