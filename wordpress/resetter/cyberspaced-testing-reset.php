<?php
    exec('/app/website/resetter/cyberspaced-testing-reset.sh', $output);
    opcache_reset();
    print_r($output);
?>
