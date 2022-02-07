module Easypay
  class NotificationsController < ApplicationController

    # unloadable

    before_filter :register_notification

    def simple_notification
      # c=PT&e=10611&r=810302231&v=7&l=PT&t_key=
      @payment_reference = PaymentReference.find_by_ep_reference_and_ep_value(params[:r], params[:v])
      @atts = params
      respond_to do |format|
        format.xml
      end
    end

    def notification_to_forward
      # e=10611&r=810302231&v=7&s=ok&k=C36D4995CBF3574ADD8664BA26514181C9EA8737&t_key=CCCSOKCSO
      payment_reference = PaymentReference.find_by_ep_reference_and_ep_key(params[:r], params[:t_key])

      if params[:s].starts_with? "ok" and params[:k].present? and payment_reference.present?
        payment_reference.update_attribute(:o_key, params[:k]) unless payment_reference.nil?

        payment_detail = Client.new.request_payment(params[:e], params[:r], params[:v], params[:k])

        payment_reference.update_attributes(:ep_last_status => payment_detail[:ep_status],
                                            :ep_message => payment_detail[:ep_message]) unless payment_reference.nil?

      elsif payment_reference.present?
        payment_reference.update_attribute(:ep_last_status, params[:s])
      end

      # redirects to thankyou page, since the notification comes after
      redirect_to thankyou_order_path(:easypay => 'done')
    end

    def notification_from_payment
      # ep_cin=8103&ep_user=OUTITUDE&ep_doc=TESTOUTITUDE0088690520120712152503
      payment_detail = Client.new.get_payment_detail("", params[:ep_doc], params[:ep_type])
      payment_detail = payment_detail["getautoMB_detail"]

      @payment_reference = PaymentReference.find_by_ep_reference_and_ep_key(payment_detail["ep_reference"], payment_detail["t_key"])

      if @payment_reference.present? and !@payment_reference.ep_status.match('finalized')

        @payment_reference.update_attributes(:ep_doc => payment_detail["ep_doc"],
                                            :ep_payment_type => payment_detail["ep_payment_type"],
                                            :ep_value_fixed => payment_detail["ep_value_fixed"],
                                            :ep_value_var => payment_detail["ep_value_var"],
                                            :ep_value_tax => payment_detail["ep_value_tax"],
                                            :ep_value_transf => payment_detail["ep_value_transf"],
                                            :ep_date_transf => payment_detail["ep_date_transf"],
                                            :ep_date_read => payment_detail["ep_date_read"],
                                            :ep_status_read => payment_detail["ep_status_read"],
                                            :o_obs => payment_detail["o_obs"],
                                            :ep_date => payment_detail["ep_date"],
                                            :ep_status => 'finalized')

        # TODO validates the url for using as a gem
        redirect_to confirm_payment_order_url(@payment_reference.ep_key) and return
      end

    end

    private

    def register_notification
      Log.create(:request_type => "Notification", :request_url => request.fullpath, :request_remote_ip => request.remote_ip)
    end
  end
end
