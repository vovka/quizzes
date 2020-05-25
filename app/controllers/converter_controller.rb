class ConverterController < ApplicationController
  DEMO = <<~EOS.freeze
    #Quiz title (with missing space after #)
    ## Question 1 title
    - [ ] Wrong Answer 1
    - [] Wrong Answer 2
    -[] Wrong Answer 3
    -[]Wrong Answer 4
    - [x] Correct Answer 5
    - [X] Correct Answer 6
    -[x] Correct Answer 7
    -[X] Correct Answer 8
    -[x]Correct Answer 9
    -[X]Correct Answer 10
    ###Correction comment of the question 1 (with missing space after #)

    ##Question 2 title (with missing space after #)
    - [ ] Wrong Answer 1x
    - [  x   ]  Correct Answer x
    - [ ] Wrong Answer 2x
    ### Correction comment of the question 2
  EOS

  def index
    @document = Document.new(source: DEMO)
  end

  def create
    @document = Document.create(document_params)
    render :index
  end

  private

  def document_params
    params.require(:document).permit(:source)
  end
end
