function flag = areJointsInRange(joints)
    flag = true;
    for i = 1:7
        switch i
            case 1
                if any(joints(:,i) > 50) | any(joints(:,i) < -100)
                    flag = false;
                    break;
                end
            case 2
                if any(joints(:,i) > 90) | any(joints(:,i) < -80)
                    flag = false;
                    break;
                end
            case 3
                if any(joints(:,i) > 90) | any(joints(:,i) < -75)
                    flag = false;
                    break;
                end
            case 4
                if any(joints(:,i) > 140) | any(joints(:,i) < 5)
                    flag = false;
                    break;
                end
            case 5
                if any(joints(:,i) > 90 )| any(joints(:,i) < -90)
                    flag = false;
                    break;
                end
            case 6
                if any(joints(:,i) > 90) | any(joints(:,i) < -75)
                    flag = false;
                    break;
                end
            case 7
                if any(joints(:,i) > 45) | any(joints(:,i) < -60)
                    flag = false;
                    break;
                end
    end
end