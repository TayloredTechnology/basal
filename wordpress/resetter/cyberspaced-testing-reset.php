<?php
    exec('/public/resetter/cyberspaced-testing-reset.sh', $output);
    opcache_reset();
    print_r($output);
?>
