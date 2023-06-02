require "rails_helper"

feature "Paper's track info" do
  feature "When tracks feature is enabled" do
    before do
      skip_paper_repo_url_check
      allow(Repository).to receive(:editors).and_return(["@editor_1", "@editor_2"])
    end

    around do |ex|
      enable_feature(:tracks) do
        @track_1 = create(:track, name: "Astrophysics", short_name: "ASTRO", code: "42")
        @track_2 = create(:track, name: "Biology", short_name: "BIO", code: "34")
        @paper = create(:paper)

        ex.run
      end
    end

    scenario "Is not public" do
      visit paper_path(@paper)
      expect(page).to_not have_css("#track-info")
    end

    scenario "Is not available to non-eic users" do
      login_as create(:user, editor: create(:editor))
      visit paper_path(@paper)
      expect(page).to_not have_css("#track-info")
    end

    scenario "Is visible to AEiCs" do
      login_as create(:admin_user, editor: create(:board_editor))
      visit paper_path(@paper)
      expect(page).to have_css("#track-info")
    end

    feature "Logged as an admin" do
      before do
        @aeic = create(:admin_user, editor: create(:board_editor))
        @track = create(:track, name: "Testing track", short_name: "TE", code: "33")
        login_as(@aeic)
      end

      feature "For new submitted papers" do
        scenario "Show info for papers with no suggested subject" do
          @paper.update(suggested_subject: nil, track_id: nil, meta_review_issue_id: nil)

          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to have_content("Author didn't suggest any subject for this paper.")
          }
        end

        scenario "Show info for papers with suggested subject" do
          @paper.update!(suggested_subject: "Solar Astronomy", track_id: @track_1.id, meta_review_issue_id: nil)

          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to_not have_content("Author didn't suggest any subject for this paper.")

            expect(page).to have_content("Author suggested this paper' subject is Solar Astronomy")
            expect(page).to have_content("This submission will be assigned to the track: Astrophysics")
          }
        end

        scenario "Show form to change track" do
          @paper.update!(suggested_subject: "Solar Astronomy", track_id: @track_1.id, meta_review_issue_id: nil)

          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to have_css("select#track_id")
            expect(page).to have_css("input[type='submit']")
          }
        end
      end

      feature "For papers with ongoing (meta)review" do
        before do
          @paper.update(suggested_subject: "Solar astronomy", track_id: @track_1.id, meta_review_issue_id: 3333, state: "review_pending")
        end

        scenario "Show info for papers assigned to a track" do
          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to_not have_content("Author didn't suggest any subject for this paper.")
            expect(page).to_not have_content("Author suggested this paper' subject is Solar Astronomy")

            expect(page).to have_content("This paper is assigned to the track: Astrophysics")
            expect(page).to have_content("This track is managed by:")
            expect(page).to have_content(@track_1.aeics.first.full_name)
            expect(page).to have_content(@track_1.aeics.first.login)
          }
        end

        scenario "Show info for papers without track" do
          @paper.update(track_id: nil)
          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to_not have_content("This paper is assigned to the track: Astrophysics")
            expect(page).to_not have_content("This track is managed by:")
            expect(page).to_not have_content(@track_1.aeics.first.full_name)
            expect(page).to_not have_content(@track_1.aeics.first.login)
          }
        end

        scenario "Show form to change track" do
          visit paper_path(@paper)

          within("#track-info"){
            expect(page).to have_css("select#track_id")
            expect(page).to have_css("input[type='submit'][value=\"Change paper's track\"]")
          }
        end

        scenario "Change paper's track" do
          allow_any_instance_of(Octokit::Client).to receive(:remove_label)
          allow_any_instance_of(Octokit::Client).to receive(:add_labels_to_an_issue)

          visit paper_path(@paper)

          within("#track-info"){
            select @track_2.name, from: "track_id"
            click_on "Change paper's track"
          }

          expect(page).to have_content("Track for the paper changed!")
          visit paper_path(@paper)

          expect(page).to have_content("This paper is assigned to the track: Biology")
          expect(page).to have_content("This track is managed by:")
          expect(page).to have_content(@track_2.aeics.first.full_name)
          expect(page).to have_content(@track_2.aeics.first.login)
        end
      end
    end
  end

  feature "When tracks feature is disabled" do
    scenario "There is no tracks info" do
      disable_feature(:tracks) do
        allow(Repository).to receive(:editors).and_return(["@editor_1", "@editor_2"])
        skip_paper_repo_url_check
        paper = create(:paper)

        visit paper_path(paper)
        expect(page).to_not have_css("#track-info")

        login_as create(:user, editor: create(:editor))
        visit paper_path(paper)
        expect(page).to_not have_css("#track-info")

        login_as create(:admin_user, editor: create(:board_editor))
        visit paper_path(paper)
        expect(page).to_not have_css("#track-info")
        expect(page).to_not have_content("Track")
        expect(page).to_not have_css("select#track_id")
        expect(page).to_not have_css("input[type='submit'][value=\"Change paper's track\"]")
      end
    end
  end
end
