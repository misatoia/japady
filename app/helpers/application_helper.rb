module ApplicationHelper

    def nengappi(date)
        "#{@user.authorized_at.strftime("%Y-%m-%d %H:%M:%S")}"
    end
end
