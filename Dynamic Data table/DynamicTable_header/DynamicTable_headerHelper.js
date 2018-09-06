({
    sortUp: function(prop) {
        return function(a, b) {
            if (a[prop] > b[prop]) {
                return 1;
            } else if (a[prop] < b[prop]) {
                return -1;
            }
            return 0;
        }
    },
    sortDown: function(prop) {
        return function(a, b) {
            if (a[prop] < b[prop]) {
                return 1;
            } else if (a[prop] > b[prop]) {
                return -1;
            }
            return 0;
        }
    }
})