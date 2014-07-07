

            ip_p = re.compile("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
            ip_m = ip_p.match(m.group(1))
            if not ip_m:
                print "not a valid ip %s" % m.group(1)
                rv = False
            else:
                print "valid ip %s" % m.group(1)

            ip_m = ip_p.match(m.group(2))
            if not ip_m:
                print "not a valid ip %s" % m.group(2)
                rv = False
            else:
                print "valid ip %s" % m.group(2)
