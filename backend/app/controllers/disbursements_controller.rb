class DisbursementsController < ApplicationController
  def index
    @disbursements = Disbursement.includes([:order])

    # start_time and end_time must be both present.
    # if none are present, set the defaults to be last week.
    if [params[:start_time], params[:end_time]].all?(&:blank?)
      start_time = Time.current.beginning_of_week - 1.week
      end_time = Time.current.end_of_week - 1.week
    elsif [params[:start_time], params[:end_time]].any?(&:blank?)
      raise StandardError, 'Both start_time and end_time are required'
    else
      start_time = DateTime.parse(params[:start_time])
      end_time = DateTime.parse(params[:end_time])
    end
    raise StandardError, 'start_time must be before end_time' unless start_time < end_time

    @disbursements = @disbursements.where(order: { completed_at: start_time...end_time })

    merchant = Merchant.find_by!(id: params[:merchant_id]) if params[:merchant_id]
    @disbursements = @disbursements.where(order: { merchant: merchant }) if merchant

    render :index, formats: :json
  rescue ActiveRecord::RecordNotFound
    raise StandardError, 'The merchant id provided is not valid'
  end
end
