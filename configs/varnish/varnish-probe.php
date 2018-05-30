<?php
echo 1;
/**
 * @file
 *   A health-check probe for Varnish.
 *
 *   Based on the probe found here
 *   http://www.lullabot.com/blog/article/configuring-varnish-high-availability-multiple-web-servers
 */
// Register our shutdown function so that no other shutdown functions run before this one.
// This shutdown function calls exit(), immediately short-circuiting any other shutdown functions,
// such as those registered by the devel.module for statistics.
register_shutdown_function('status_shutdown');
function status_shutdown() {
  exit();
}

// Drupal bootstrap.
require_once './includes/bootstrap.inc';
drupal_bootstrap(DRUPAL_BOOTSTRAP_DATABASE);
// Build up our list of errors.
$errors = array();
// Check that the main database is active.
$result = db_query('SELECT * FROM {users} WHERE uid = 1');
$account = db_fetch_object($result);
if (!$account->uid == 1) {
  $errors[] = 'Master database not responding.';
}
// Check that the files directory is operating properly.
if ($test = tempnam(variable_get('file_directory_path', conf_path() .'/files'), 'status_check_')) {
  // Uncomment to check if files are saved in the correct server directory.
  //if (!strpos($test, '/mnt/nfs') === 0) {
  //  $errors[] = 'Files are not being saved in the NFS mount under /mnt/nfs.';
  //}
  if (!unlink($test)) {
    $errors[] = 'Could not delete newly create files in the files directory.';
  }
}
else {
  $errors[] = 'Could not create temporary file in the files directory.';
}
// Print all errors.
if ($errors) {
  $errors[] = 'Errors on this server will cause it to be removed from the load balancer.';
  header('HTTP/1.1 500 Internal Server Error');
  print implode("<br />\n", $errors);
}
else {
  // Split up this message, to prevent the remote chance of monitoring software
  // reading the source code if mod_php fails and then matching the string.
  print 'CONGRATULATIONS' . ' 200';
}
// Exit immediately, note the shutdown function registered at the top of the file.
exit();
